import UIKit

final class UserCell: UITableViewCell, ConfigurableCell {
    
    typealias T = User
    static let identifier = "UserCell"
    static let formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY.MM.dd в HH:mm"
        return formatter
    }()
    
    var onEditingChanged: ((_ editing: Bool) -> Void)?
    
    func configure(with object: User) {
        textLabel?.text = object.name
        if let lastSession = object.sessions?.lastObject as? Session,
            let lastWorkoutDate = lastSession.workout?.date {
            
            let dateString = UserCell.formatter.string(from: lastWorkoutDate as Date)
            detailTextLabel?.text = "Занимался \(dateString)"
        } else {
            detailTextLabel?.text = "Еще не занимался"
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        onEditingChanged?(editing)
    }
}
