import UIKit
import Firebase

final class WorkoutTypeCell: UITableViewCell, ConfigurableCell {
    
    typealias T = WorkoutType
    static let identifier = "WorkoutTypeCell"
    
    func configure(with object: WorkoutType) {
        textLabel?.text = object.title
    }
}

final class WorkoutTypeListViewController: FirebaseListViewController<WorkoutType, WorkoutTypeCell> {
    
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
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.WorkoutType)], Error>) in
                switch result {
                case let .success(value):
                    self?.dataSource = value.map { WorkoutType(firebaseData: $0.1, remoteId: $0.0, createdBy: nil) }
                    self?.tableView.reloadData()
                case .failure:
// TODO: - Handle error
                    break
                }
            }
        ))
    }
}
