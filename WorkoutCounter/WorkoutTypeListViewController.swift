import UIKit
import Firebase

final class WorkoutTypeCell: UITableViewCell, ConfigurableCell {
    
    typealias T = ActivityType
    static let identifier = "WorkoutTypeCell"
    
    func configure(with object: ActivityType) {
        textLabel?.text = object.title
    }
}

final class WorkoutTypeListViewController: FirebaseListViewController<ActivityType, WorkoutTypeCell> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            WorkoutTypeCell.self,
            forCellReuseIdentifier: WorkoutTypeCell.identifier
        )
    }
    
    override func signupForUpdates() {
        signupForGoalsUpdates()
    }
    
    func signupForGoalsUpdates() {
        listeners.append(Firestore.firestore().getObjects(
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.ActivityType)], Error>) in
                switch result {
                case let .success(value):
                    self?.dataSource = value.map { ActivityType(firebaseData: $0.1, remoteId: $0.0, createdBy: nil) }
                case .failure:
// TODO: - Handle error
                    break
                }
            }
        ))
    }
}
