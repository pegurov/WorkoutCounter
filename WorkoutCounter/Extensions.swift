import UIKit
import MBProgressHUD





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
