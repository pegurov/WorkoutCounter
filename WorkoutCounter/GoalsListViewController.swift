import Firebase
import UIKit

final class GoalCell: UITableViewCell, ConfigurableCell {
    
    typealias T = User.Goal
    static let identifier = "GoalCell"

    func configure(with object: User.Goal) {
        textLabel?.text = object.activity?.title
        detailTextLabel?.text = "Количество повторений: \(object.count.clean)"
    }
}

final class GoalsListViewController: FirebaseListViewController<User.Goal, GoalCell> {
    
    var userId: String!
    var user: FirebaseData.User?
    var activities: [String: FirebaseData.Activity] = [:]
    
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
                self?.signupForActivitiesUpdates(ids: user.1.goals?.map { $0.activity } ?? [])
            case .failure:
// TODO: - Handle error
                break
            }
        })
    }
    
    func signupForActivitiesUpdates(ids: [String]) {
        activities = [:]
        guard !ids.isEmpty else {
            makeDataSource()
            return
        }
        let counter = Counter()
        
        ids.forEach { id in
            counter.increment()
            listeners.append(Firestore.firestore().getObject(id: id) { [weak self] (result: Result<(String, FirebaseData.Activity), Error>) in
                switch result {
                case let .success(id, activty):
                    self?.activities[id] = activty
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
        dataSource = (user!.goals ?? []).map { goal in
            return User.Goal(
                firebaseData: goal,
                activity: makeActivity(id: goal.activity)
            )
        }
    }
    
    private func makeActivity(id: String) -> Activity? {
        guard let data = activities[id] else { return nil }
        return Activity(firebaseData: data, remoteId: id)
    }
}
