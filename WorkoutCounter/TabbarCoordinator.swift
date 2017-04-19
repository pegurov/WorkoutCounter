import UIKit

final class TabbarCoordinator: Coordinator {
    
    var onLogout: (() -> Void)?
    private let storyboard: UIStoryboard = .tabbar
    private var rootViewController: UIViewController?
    
    private var coreDataStack: CoreDataStack
    private var workoutCoordinator: WorkoutCoordinator
    private var profileCoordinator: ProfileCoordinator
    
    init(coreDataStack: CoreDataStack) {
        
        self.coreDataStack = coreDataStack
        self.workoutCoordinator = WorkoutCoordinator(
            coreDataStack: coreDataStack
        )
        self.profileCoordinator = ProfileCoordinator()
    }
    
    func start() -> UIViewController {
        
        self.profileCoordinator.onLogout = onLogout
        let tabbarController =
            storyboard.instantiateInitialViewController() as! UITabBarController
        tabbarController.viewControllers = [
            workoutCoordinator.start(),
            profileCoordinator.start()
        ]
        rootViewController = tabbarController
        return tabbarController
    }
}
