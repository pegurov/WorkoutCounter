import UIKit
import Firebase

final class RootCoordinator {
    
    private var authProvider: AuthProvider
    private var applicationCoordinator: ApplicationCoordinator?
    private var authCoordinator: AuthCoordinator?
    private weak var window: UIWindow!
    var subscriptions: [ListenerRegistration] = []
    var hasNeverBeenDeauthorized = true
    var versionIsNotSupported: Bool = UserDefaults.standard.bool(forKey: "versionIsNotSupported") {
        didSet { UserDefaults.standard.set(versionIsNotSupported, forKey: "versionIsNotSupported") }
    }
    
    init(
        authProvider: AuthProvider,
        window: UIWindow) {
        
        self.authProvider = authProvider
        self.authProvider.onAuthStateChanged = { [weak self] in
            self?.checkAuth()
        }
        checkVersion()
        
        self.window = window
        window.rootViewController = UIViewController()
    }
    
    private func checkVersion() {
        Firestore.firestore().collection("Version").document("6pt83hsJltBAeUHnCWVM").getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data() as? [String: String],
                let versionString = data["version"],
                let buildString = data["build"],
                let minimumSupportedVersion = Double(versionString),
                let minimumSupportedBuild = Double(buildString),
                let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                let buildNumberString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
                let appVersion = Double(appVersionString),
                let buildNumber = Double(buildNumberString)
            {
                let versionIsSupported = (appVersion >= minimumSupportedVersion) && (buildNumber >= minimumSupportedBuild)
                self?.versionIsNotSupported = !versionIsSupported
            }
            self?.checkAuth()
        }
    }
    
    private func checkAuth() {
        guard !versionIsNotSupported else {
            window.rootViewController = UIStoryboard.unsupportedVersion.instantiateInitialViewController()
            return
        }
        
        if authProvider.authorized, let userId = authProvider.firebaseUser?.uid {
            if hasNeverBeenDeauthorized {
                showApplication()
                return
            }
            
            subscriptions.append(Firestore.firestore().getObject(id: userId) { [weak self] (result: Result<(String, FirebaseData.User), Error>) in
                switch result {
                case .success:
                    self?.showApplication(startWithProfile: true)
                case let .failure(error):
                    switch error {
                    case FirebaseError.documentDoesNotExist:
                        let newUser = FirebaseData.User(
                            name: self?.authProvider.firebaseUser?.displayName ?? userId,
                            createdAt: Date(),
                            createdBy: userId
                        )
                        Firestore.firestore().upload(object: newUser, underId: userId) { storingResult in
                            switch storingResult {
                            case .success:
                                self?.showApplication(startWithProfile: true)
                            case .failure:
                                break
// TODO: handle unknown error
                            }
                        }
                    default:
                        break
// TODO: handle unknown error
                    }
                }
            })
            
        } else {
            hasNeverBeenDeauthorized = false
            subscriptions.forEach { $0.remove() }
            authCoordinator = AuthCoordinator()
            window.rootViewController = authCoordinator?.navigationController
        }
    }
    
    private func showApplication(startWithProfile: Bool = false) {
        guard applicationCoordinator == nil else { return }
        
        subscriptions.forEach { $0.remove() }
        subscriptions = []
        
        applicationCoordinator = ApplicationCoordinator(authProvider: authProvider, startWithProfile: startWithProfile)
        applicationCoordinator?.onLogout = { [weak self] in
            self?.authProvider.logout()
        }
        window.rootViewController = applicationCoordinator?.rootViewController
    }
}
