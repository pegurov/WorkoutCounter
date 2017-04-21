import UIKit
import FirebaseAuthUI

final class AuthCoordinator {
    
    var navigationController: UINavigationController
    
    init() {
        navigationController = FUIAuth.defaultAuthUI()!.authViewController()
    }
}
