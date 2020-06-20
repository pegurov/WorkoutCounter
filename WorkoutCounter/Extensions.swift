import UIKit
import MBProgressHUD

extension UIStoryboard {
    
    static let user = UIStoryboard(name: "User", bundle: Bundle.main)
    static let workout = UIStoryboard(name: "Workout", bundle: Bundle.main)
    static let workoutCreate = UIStoryboard(name: "WorkoutCreate", bundle: Bundle.main)
    static let tabbar = UIStoryboard(name: "Tabbar", bundle: Bundle.main)
    static let profile = UIStoryboard(name: "Profile", bundle: Bundle.main)
    static let auth = UIStoryboard(name: "Auth", bundle: Bundle.main)
    static let workoutType = UIStoryboard(name: "WorkoutType", bundle: Bundle.main)
    
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

extension Array {
    
    @discardableResult
    mutating func removeWhere(_ condition:((Element) -> Bool)) -> Element? {
        
        if let index = firstIndex(where: condition) {
            return remove(at: index)
        }
        return nil
    }
}

extension Session {
    
    var setsDescription: String {
        guard let sets = sets?.array as? [WorkoutSet],
            !sets.isEmpty else { return "Пока нет подходов" }
        
        var description = "[\(sets.count)] "
        var totalCount: Int16 = 0
        let sortedSets = sets.sorted { set1, set2 in
            if let time1 = set1.time, let time2 = set2.time {
                return time1.timeIntervalSince1970 < time2.timeIntervalSince1970
            } else if let id1 = set1.remoteId, let id2 = set2.remoteId {
                return id1 < id2
            }
            return true
        }
        sortedSets.enumerated().forEach { index, set in
            
            description += (index == 0 ? "" : "+") + "\(set.count)"
            totalCount += set.count
        }
        description += "=\(totalCount)"
        return description
    }
}
