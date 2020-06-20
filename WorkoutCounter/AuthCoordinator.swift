import UIKit
import FirebaseAuth
import FirebaseUI

final class AuthCoordinator {
    
    var navigationController: UINavigationController
    
    init() {
        navigationController = FUIAuth.defaultAuthUI()!.authViewController()
    }
}
