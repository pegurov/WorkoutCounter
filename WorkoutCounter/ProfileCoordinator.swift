import UIKit

final class ProfileCoordinator: Coordinator {
    
    var onLogout: (() -> Void)?
    private let storyboard: UIStoryboard = .profile
    private var rootViewController: UIViewController!
    
    // MARK: - Coordinator -
    func start() -> UIViewController {
        
        let navigation =
            storyboard.instantiateInitialViewController() as! UINavigationController
        let profileVC = navigation.topViewController as! ProfileViewController
        configureProfile(profileVC)
        rootViewController = navigation
        return navigation
    }
    
    private func configureProfile(_ controller: ProfileViewController) {
        controller.onLogout = onLogout
    }
}
