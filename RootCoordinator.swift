import UIKit
import Firebase

final class RootCoordinator {
    
    private var authProvider: AuthProvider
    private var applicationCoordinator: ApplicationCoordinator?
    private var authCoordinator: AuthCoordinator?
    private weak var window: UIWindow!

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

// На каждый старт конечно невыгодно чекать юзера, кажется это надо делать только один раз после авторизации и все
// И потом где-то какой-то флаг запоминать про то, что такого юзера уже создали
            
// Кейс - авторизуешься юзером, потом сносишь его на сервере из таблицы User
// открываешь приложение и он все еще тут, хотя на сервере его уже нет
// и он не загружается
            
            Firestore.firestore().getObject(id: userId) { [weak self] (result: Result<User, Error>) in
                switch result {
                case .success:
                    self?.showApplication()
                case let .failure(error):
                    switch error {
                    case FirebaseError.documentDoesNotExist:
                        let newUser = User(
                            name: self?.authProvider.firebaseUser?.displayName ?? userId,
                            createdAt: Date(),
                            createdBy: userId
                        )
                        Firestore.firestore().store(object: newUser, underId: userId) { storingResult in
                            switch storingResult {
                            case .success:
                                self?.showApplication()
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
            }
            
// Все вот это добро не будет работать без интернета
//            authProvider.updateCurrentUser { [weak self] wasUserUpdateSuccessfull in
//                guard
//                    let firebaseUser = self?.authProvider.firebaseUser,
//                    wasUserUpdateSuccessfull
//                else {
//// TODO: - Show alert that the user cannot be updated
//                    return
//                }
// TODO: -
// Короче updateCurrentUser не помогает и юзер все равно не имеет user.displayName
// Поэтому в поле name залетает сразу uuid и все

//                self?.showApplication()
                

                
                
                
                
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
//            }
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
