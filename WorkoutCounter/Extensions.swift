import UIKit
import MBProgressHUD

extension UIStoryboard {

    static let today = UIStoryboard(name: "Today", bundle: Bundle.main)
    static let activities = UIStoryboard(name: "Activities", bundle: Bundle.main)
    static let profile = UIStoryboard(name: "Profile", bundle: Bundle.main)
    static let unsupportedVersion = UIStoryboard(name: "UnsupportedVersion", bundle: Bundle.main)
    static let feed = UIStoryboard(name: "Feed", bundle: Bundle.main)
    
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
        
        if let view = navigationController?.view ?? view, MBProgressHUD.forView(view) == nil {
            
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

extension Date {

    var withoutTime: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
}

extension Workout.Session {
    
    var shortSetsDescription: String {
        var description = "\(sets.reduce(0){ $0 + $1.count })"
        if let goal = goal {
            description += " из \(goal.count)"
        }
        return description
    }
    
    var setsDescription: String {
        var description: String = ""
        if sets.isEmpty {
            description = "0"
        } else if sets.count == 1 {
            description = "\(sets[0].count)"
        } else {
            var totalCount = 0
            sets.enumerated().forEach { index, set in
                description += (index == 0 ? "" : "+") + "\(set.count)"
                totalCount += set.count
            }
            description += " = \(totalCount)"
        }
        if let goal = goal {
            description += " из \(goal.count)"
        }
        return description
    }
}
