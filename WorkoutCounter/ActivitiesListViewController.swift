import UIKit

final class ActicityCell: UITableViewCell, ConfigurableCell {
    
    static var identifier = "ActicityCell"
    
    typealias T = Activity
    
    func configure(with object: Activity) {
        textLabel?.text = object.type?.title
        detailTextLabel?.text = object.setsDescription
    }
}

final class ActivitiesListViewController: FirebaseListViewController<Activity, ActicityCell> {
    
    
}
