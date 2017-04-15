import UIKit

final class UserCell: UITableViewCell, ConfigurableCell {
    
    typealias T = User
    static let identifier = "UserCell"
    static let formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MM dd в HH:mm"
        return formatter
    }()
    
    func configure(with object: User) {
        textLabel?.text = object.name
        if let lastWorkoutDate = (object.workouts?.lastObject as? Workout)?.date {
            
            let dateString = UserCell.formatter.string(from: lastWorkoutDate as Date)
            detailTextLabel?.text = "Занимался \(dateString)"
        } else {
            detailTextLabel?.text = "Еще не занимался"
        }
    }
}
