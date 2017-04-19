import UIKit
import FirebaseAuthUI

final class AuthCoordinator: Coordinator {
    
    private var rootViewController: UIViewController!
    
    // MARK: - Coordinator -
    func start() -> UIViewController {

        let navigation = FUIAuth.defaultAuthUI()!.authViewController()
        rootViewController = navigation
        return navigation
    }
}
