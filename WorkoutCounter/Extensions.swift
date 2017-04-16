import UIKit

extension UIStoryboard {
    
    static let user = UIStoryboard(name: "User", bundle: Bundle.main)
    static let workout = UIStoryboard(name: "Workout", bundle: Bundle.main)
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
