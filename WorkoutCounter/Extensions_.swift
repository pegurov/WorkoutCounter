import UIKit
import MBProgressHUD

extension UIStoryboard {
    
//    static let user = UIStoryboard(name: "User", bundle: Bundle.main)
//    static let workout = UIStoryboard(name: "Workout", bundle: Bundle.main)
//    static let workoutCreate = UIStoryboard(name: "WorkoutCreate", bundle: Bundle.main)
//    static let tabbar = UIStoryboard(name: "Tabbar", bundle: Bundle.main)
//    static let auth = UIStoryboard(name: "Auth", bundle: Bundle.main)
//    static let workoutType = UIStoryboard(name: "WorkoutType", bundle: Bundle.main)

    static let profile = UIStoryboard(name: "Profile", bundle: Bundle.main)
    
    var initialNavigation: UINavigationController {
        return instantiateInitialViewController() as! UINavigationController
    }
}


extension UIViewController {
    
    func startActivityIndicator() {
        
        let nib = Bundle.main.loadNibNamed("ActivityView", owner: nil, options: nil)
        let view = nib?.first as? UIView
        navigationItem.titleView = view
    }
    
    func stopActivityIndicator() {
        navigationItem.titleView = nil
    }
    
    func showProgressHUD() {
        
        if let view = navigationController?.view ?? view {
            
            let hud = MBProgressHUD.showAdded(
                to: view,
                animated: true
            )
            hud.removeFromSuperViewOnHide = true
            hud.isUserInteractionEnabled = true
        }
    }
    
    func hideProgressHUD() {
        
        if let view = navigationController?.view ?? view {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}
