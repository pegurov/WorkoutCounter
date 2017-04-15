import UIKit

extension UIStoryboard {
    
    static var users: UIStoryboard {
        return UIStoryboard(name: "Users", bundle: Bundle.main)
    }
}

extension Array {
    
    @discardableResult
    mutating func removeWhere(_ condition:((Element) -> Bool)) -> Bool {
        
        if let index = index(where: condition) {
            remove(at: index)
            return true
        }
        return false
    }
}
