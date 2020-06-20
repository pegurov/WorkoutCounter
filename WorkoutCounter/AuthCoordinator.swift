import UIKit
import FirebaseAuth
import FirebaseUI

final class AuthCoordinator: NSObject, FUIAuthDelegate {
    
    var navigationController: UINavigationController
    private let authUI = FUIAuth.defaultAuthUI()!
    
    override init() {
        authUI.providers = [
            FUIEmailAuth()
        ]
// TODO: - email verification
        authUI.shouldHideCancelButton = true
        navigationController = FUIAuth.defaultAuthUI()!.authViewController()
    }
    
    // MARK: - FUIAuthDelegate
}
