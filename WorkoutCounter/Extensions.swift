import UIKit

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
}

extension Array {
    
    @discardableResult
    mutating func removeWhere(_ condition:((Element) -> Bool)) -> Element? {
        
        if let index = index(where: condition) {
            return remove(at: index)
        }
        return nil
    }
}

extension Session {
    
    var setsDescription: String {
        guard let sets = sets?.array as? [WorkoutSet],
            !sets.isEmpty else { return "Пока нет подходов" }
        
        var description = ""
        var totalCount: Int16 = 0
        sets.enumerated().forEach { index, set in
            
            description += (index == 0 ? "" : "+") + "\(set.count)"
            totalCount += set.count
        }
        description += "=\(totalCount)"
        return description
    }
}
