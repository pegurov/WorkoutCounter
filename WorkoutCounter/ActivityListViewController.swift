import UIKit
import Firebase

final class ActivityCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Activity
    static let identifier = "ActivityCell"
    
    func configure(with object: Activity) {
        textLabel?.text = object.title
    }
}

final class ActivityListViewController: FirebaseListViewController<Activity, ActivityCell> {
    
    // MARK: - Output
    var onAddTap: (() -> ())?

    @IBAction func addTap(_ sender: UIBarButtonItem) {
        onAddTap?()
    }
    
    override func signupForUpdates() {
        signupForGoalsUpdates()
    }
    
    func signupForGoalsUpdates() {
        listeners.append(Firestore.firestore().getObjects(
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Activity)], Error>) in
                switch result {
                case let .success(value):
                    self?.dataSource = value.map { Activity(firebaseData: $0.1, remoteId: $0.0, createdBy: nil) }
                case .failure:
// TODO: - Handle error
                    break
                }
            }
        ))
    }
}
