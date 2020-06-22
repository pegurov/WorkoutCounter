import UIKit

final class UserCell: UITableViewCell, ConfigurableCell {
    
    typealias T = User
    static let identifier = "UserCell"
//    static let formatter: DateFormatter = {
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "YYYY.MM.dd в HH:mm"
//        return formatter
//    }()
    
//    var onEditingChanged: ((_ editing: Bool) -> Void)?
    
    func configure(with object: User) {
        textLabel?.text = object.name
//        if let sessionsCount = object.sessions?.count {
//            detailTextLabel?.text = "Тренировок: \(sessionsCount)"
//        } else {
            detailTextLabel?.text = "Еще не занимался"
//        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
//        onEditingChanged?(editing)
    }
}
