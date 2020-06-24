import UIKit
import Firebase

final class RootCoordinator {
    
    private var authProvider: AuthProvider
    private var applicationCoordinator: ApplicationCoordinator?
    private var authCoordinator: AuthCoordinator?
    private weak var window: UIWindow!
    var subscriptions: [ListenerRegistration] = []
    var hasNeverBeenDeauthorized = true
    
    init(
        authProvider: AuthProvider,
        window: UIWindow) {
        
        self.authProvider = authProvider
        self.authProvider.onAuthStateChanged = { [weak self] in
            self?.checkAuth()
        }
        self.window = window
        window.backgroundColor = .white
        window.rootViewController = UIViewController()
    }
    
    private func checkAuth() {
        
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
        subscriptions.forEach { $0.remove() }
        applicationCoordinator = ApplicationCoordinator(authProvider: authProvider, startWithProfile: startWithProfile)
        applicationCoordinator?.onLogout = { [weak self] in
            self?.authProvider.logout()
        }
        window.rootViewController = applicationCoordinator?.rootViewController
    }
}
