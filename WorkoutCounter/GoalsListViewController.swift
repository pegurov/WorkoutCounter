import Firebase
import UIKit

final class GoalCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Goal
    static let identifier = "GoalCell"

    func configure(with object: Goal) {
        textLabel?.text = object.type!.title
        detailTextLabel?.text = "Количество повторений: \(object.count)"
    }
}

final class GoalsListViewController: FirebaseListViewController<Goal, GoalCell> {
    
    var userId: String!
    var user: FirebaseData.User?
    var types: [String: FirebaseData.ActivityType] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: "GoalCell", bundle: .main),
            forCellReuseIdentifier: GoalCell.identifier
        )
    }
    
    override func signupForUpdates() {
        guard listeners.isEmpty else { return }
        
        resignFromUpdates()
        signupForUserUpdates()
    }
    
    func signupForUserUpdates() {
        user = nil
        listeners.append(Firestore.firestore().getObject(id: userId) { [weak self] (result: Result<(String, FirebaseData.User), Error>) in
            switch result {
            case .success(let user):
                self?.user = user.1
                self?.signupForWorkoutTypesUpdates(ids: user.1.goals.map { $0.type })
            case .failure:
// TODO: - Handle error
                break
            }
        })
    }
    
    func signupForWorkoutTypesUpdates(ids: [String]) {
        types = [:]
        guard !ids.isEmpty else {
            makeDataSource()
            return
        }
        let counter = Counter()
        
        ids.forEach { id in
            counter.increment()
            listeners.append(Firestore.firestore().getObject(id: id) { [weak self] (result: Result<(String, FirebaseData.ActivityType), Error>) in
                switch result {
                case let .success(id, type):
                    self?.types[id] = type
                case .failure:
// TODO: - Handle error
                    break
                }
                counter.decrement {
                    self?.makeDataSource()
                }
            })
        }
    }
    
    private func makeDataSource() {
        dataSource = user!.goals.map { goal in
            return Goal(
                firebaseData: goal,
                type: makeActivityType(id: goal.type)
            )
        }
    }
    
    private func makeActivityType(id: String) -> ActivityType? {
        guard let data = types[id] else { return nil }
        return ActivityType(firebaseData: data, remoteId: id)
    }
}
