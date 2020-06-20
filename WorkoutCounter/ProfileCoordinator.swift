import UIKit

final class ProfileCoordinator: StoryboardCoordinator<ProfileViewController> {
    
    // MARK: - Output -
    var onLogout: (() -> Void)? {
        get { return rootViewController.onLogout }
        set { rootViewController.onLogout = newValue }
    }
}
