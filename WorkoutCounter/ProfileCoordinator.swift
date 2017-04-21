import UIKit

final class ProfileCoordinator: Coordinator {
    
    var onLogout: (() -> Void)?
    private let storyboard: UIStoryboard = .profile
    private var rootViewController: UIViewController!
    
    // MARK: - Coordinator -
    func start() -> UIViewController {
        
        let profileVC = storyboard.instantiateInitialViewController() as! ProfileViewController
        configureProfile(profileVC)
        rootViewController = profileVC
        return profileVC
    }
    
    private func configureProfile(_ controller: ProfileViewController) {
        controller.onLogout = onLogout
    }
}
