import UIKit
import FirebaseAuth

final class ApplicationCoordinator {
    
    private var authProvider: AuthProvider
    private var coreDataStack: CoreDataStack
    private var tabbarCoordinator: TabbarCoordinator?
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
            tabbarCoordinator = TabbarCoordinator(coreDataStack: coreDataStack)
            tabbarCoordinator?.onLogout = { [weak self] in
                self?.authProvider.logout()
            }
            window.rootViewController = tabbarCoordinator?.start()
        } else {
            authCoordinator = AuthCoordinator()
            window.rootViewController = authCoordinator?.start()
        }
    }
}

