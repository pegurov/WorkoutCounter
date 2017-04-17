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

extension Session {
    
    var setsDescription: String {
        guard let sets = sets?.array as? [Set],
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
