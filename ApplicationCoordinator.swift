import UIKit
import FirebaseAuth

final class ApplicationCoordinator {
    
    private var authProvider: AuthProvider
    private var coreDataStack: CoreDataStack
    private var workoutCoordinator: WorkoutCoordinator?
    private var authCoordinator: AuthCoordinator?
    private weak var window: UIWindow!

    init(
        authProvider: AuthProvider,
        coreDataStack: CoreDataStack,
        window: UIWindow) {
        
        self.coreDataStack = coreDataStack
        self.authProvider = authProvider
        self.authProvider.onAuthStateChanged = { [weak self] in
            self?.checkAuth()
        }
        self.window = window
        window.backgroundColor = .white
    }
    
    func start() {
        checkAuth()
    }
    
    private func checkAuth() {
        
        if authProvider.authorized {
            
            workoutCoordinator = WorkoutCoordinator(
                storyboard: .workout,
                coreDataStack: coreDataStack
            )
            workoutCoordinator?.onLogout = { [weak self] in
                self?.authProvider.logout()
            }
            window.rootViewController = workoutCoordinator?.navigationController
        } else {
            
            authCoordinator = AuthCoordinator()
            window.rootViewController = authCoordinator?.navigationController
        }
    }
}

