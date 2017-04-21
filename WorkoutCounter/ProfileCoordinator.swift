import UIKit

final class ProfileCoordinator: StoryboardCoordinator<ProfileViewController> {
    
    // MARK: - Output -
    var onLogout: (() -> Void)?
    
    override func configureRootViewController(
        _ controller: ProfileViewController) {
        
        controller.onLogout = onLogout
    }
}
