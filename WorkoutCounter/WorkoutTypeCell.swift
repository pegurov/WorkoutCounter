import UIKit

final class WorkoutTypeCell: UITableViewCell, ConfigurableCell {
    
    typealias T = WorkoutType
    static let identifier = "WorkoutTypeCell"
    
    func configure(with object: WorkoutType) {
        textLabel?.text = object.title
    }
}
