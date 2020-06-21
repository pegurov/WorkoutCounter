import UIKit
import FirebaseAuth

final class RootCoordinator {
    
    private var authProvider: AuthProvider
//    private var coreDataStack: CoreDataStack
//    private var firebaseManager: FirebaseManager
    private var applicationCoordinator: ApplicationCoordinator?
    private var authCoordinator: AuthCoordinator?
    private weak var window: UIWindow!

    init(
        authProvider: AuthProvider,
//        coreDataStack: CoreDataStack,
//        firebaseManager: FirebaseManager,
        window: UIWindow) {
        
//        self.coreDataStack = coreDataStack
//        self.firebaseManager = firebaseManager
        self.authProvider = authProvider
        self.authProvider.onAuthStateChanged = { [weak self] in
            self?.checkAuth()
        }
        self.window = window
        window.backgroundColor = .white
        window.rootViewController = UIViewController()
    }
    
    func start() {
        checkAuth()
    }
    
    private func checkAuth() {
        
        if authProvider.authorized, let userId = authProvider.firebaseUser?.uid {
            
// Все вот это добро не будет работать без интернета
            authProvider.updateCurrentUser { [weak self] wasUserUpdateSuccessfull in
                guard
                    let user = self?.authProvider.firebaseUser,
                    wasUserUpdateSuccessfull
                else {
// TODO: - Show alert that the user cannot be updated
                    return
                }
// TODO: -
// Короче updateCurrentUser не помогает и юзер все равно не имеет user.displayName
// Поэтому в поле name залетает сразу uuid и все

                self?.showApplication()
                
//                if self?.checkUserExistsLocally(userId: userId) == true {
//                    self?.showApplication()
//                    return
//                }

//                self?.window.rootViewController?.showProgressHUD()
                
//                let request = ObjectsRequest(
//                    entityName: "User",
//                    mode: .ids([userId])
//                )
//                self?.firebaseManager.loadRequest(request) { users in
//                    if let _ = users.first {
//                        self?.window?.rootViewController?.hideProgressHUD()
//                        self?.showApplication()
//                    } else {
//                        FirebaseManager.sharedInstance.makeUser(firebaseId: user.uid, firebaseName: user.displayName) { user in
//                            if user != nil {
//                                self?.window?.rootViewController?.hideProgressHUD()
//                                self?.showApplication()
//                            } else {
//// TODO: - Show alert that the user cannot be created
//                            }
//                        }
//                    }
//                }
            }
        } else {
            authCoordinator = AuthCoordinator()
            window.rootViewController = authCoordinator?.navigationController
        }
    }
    
    private func showApplication() {
        applicationCoordinator = ApplicationCoordinator(
//            coreDataStack: coreDataStack
        )
        applicationCoordinator?.onLogout = { [weak self] in
            self?.authProvider.logout()
        }
        window.rootViewController = applicationCoordinator?.rootViewController
    }
    
    
//    private func checkUserExistsLocally(userId: String) -> Bool {
//        guard let result: [User] = coreDataStack.fetch(
//            entityName: "User",
//            predicate: NSPredicate(format: "remoteId == %@", userId)
//        ) else { return false}
//
//        return result.count > 0
//    }
}
