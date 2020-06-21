import UIKit

final class ProfileViewController: UIViewController {
    
    var onLogout: (() -> Void)?
    
    @IBAction func logoutTap(_ sender: UIBarButtonItem) {
        onLogout?()
    }
}

protocol ConfigurableCell {
    
    associatedtype T
    
    func configure(with object: T)
    static var identifier: String { get }
}

class FirebaseListViewController<T, C: ConfigurableCell, UITableViewCell>:
    UITableViewController
//    where C: UITableViewCell
{

    
}
