import UIKit

final class SessionCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Session
    static let identifier: String = "SessionCell"
    
    func configure(with object: Session) {
        textLabel?.text = (object.user!.name ?? "") +
            (object.active ? "" : " - закончил")
        detailTextLabel?.text = object.setsDescription
    }
}
