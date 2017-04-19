import UIKit

final class ProfileViewController: UIViewController {
    
    var onLogout: (() -> Void)?
    
    @IBAction func logoutTap(_ sender: UIButton) {
        onLogout?()
    }
}
