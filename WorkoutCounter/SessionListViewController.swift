import UIKit

final class SessionCell: UITableViewCell, ConfigurableCell {
    
    static var identifier = "SessionCell"
    
    typealias T = Workout.Session
    
    func configure(with object: Workout.Session) {
        textLabel?.text = object.activity?.title
        detailTextLabel?.text = object.setsDescription
    }
}

final class SessionListViewController: FirebaseListViewController<Workout.Session, SessionCell> {
    
}
