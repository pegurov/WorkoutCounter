import Firebase
import UIKit

final class GoalCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Goal
    static let identifier = "GoalCell"
//    static let formatter: DateFormatter = {
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "YYYY.MM.dd в HH:mm"
//        return formatter
//    }()
    
//    var onEditingChanged: ((_ editing: Bool) -> Void)?
    
    func configure(with object: Goal) {
//        textLabel?.text = object.name
//        if let sessionsCount = object.sessions?.count {
//            detailTextLabel?.text = "Тренировок: \(sessionsCount)"
//        } else {
//            detailTextLabel?.text = "Еще не занимался"
//        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
//        onEditingChanged?(editing)
    }
}


final class GoalsViewController: FirebaseListViewController<Goal, GoalCell> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: "UserCell", bundle: .main),
            forCellReuseIdentifier: UserCell.identifier
        )
    }
    
    override func signupForUpdates() {
        signupForUsersUpdates()
        
    }
    
    func signupForUsersUpdates() {
        listeners.append(Firestore.firestore().getObjects { [weak self] (result: Result<[FirebaseData.Goal], Error>) in
            switch result {
            case .success(let value):
                self?.dataSource = value.map { Goal(firebaseData: $0, type: nil, user: nil, createdBy: nil) }
                self?.tableView.reloadData()
            case .failure:
                // TODO: - Handle error
                break
            }
        })
    }
}
