import Foundation

import UIKit

final class WorkoutCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Workout
    static let identifier = "WorkoutCell"
    static let formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY.MM.dd в HH:mm"
        return formatter
    }()
    
    func configure(with object: Workout) {
        
        textLabel?.text = object.title
        if let workoutDate = object.date {
            let dateString = WorkoutCell.formatter.string(
                from: workoutDate as Date
            )
            detailTextLabel?.text = dateString
        }
    }
}
