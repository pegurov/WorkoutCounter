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
    var mainData: [(String, FirebaseData.Goal)] = []
    var dependenciesContainer: [String: [String: Any]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: "GoalCell", bundle: .main),
            forCellReuseIdentifier: GoalCell.identifier
        )
    }
    
    override func signupForUpdates() {
        signupForGoalsUpdates()
    }
    
    func signupForGoalsUpdates() {
        listeners.append(Firestore.firestore().getObjects(
            query: { [userId] collection in
                collection.whereField("user", isEqualTo: userId!)
            },
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Goal)], Error>) in
                switch result {
                case .success(let value):
                    self?.mainData = value.map { ($0.0, $0.1) }
                    self?.signupForWorkoutTypesUpdates(ids: value.map { $0.1.type })
                    
                case .failure:
// TODO: - Handle error
                    break
                }
            }
        ))
    }
    
    func signupForWorkoutTypesUpdates(ids: [String]) {
        let counter = Counter()
        
        ids.forEach { id in
            counter.increment()
            listeners.append(Firestore.firestore().getObject(id: id) { [weak self] (result: Result<(String, FirebaseData.ActivityType), Error>) in
                switch result {
                case let .success(id, type):
                    var types: [String: Any] = self?.dependenciesContainer["types"] ?? [:]
                    types[id] = type
                    self?.dependenciesContainer["types"] = types
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
        guard let types = dependenciesContainer["types"] as? [String: FirebaseData.ActivityType] else { return }
        
        dataSource = mainData.map { (id, goal) in
            
            let workoutType: ActivityType?
            if let firebaseData = types[goal.type] {
                workoutType = ActivityType(
                    firebaseData: firebaseData,
                    remoteId: goal.type,
                    createdBy: nil
                )
            } else {
                workoutType = nil
            }
            return Goal(
                firebaseData: goal,
                remoteId: id,
                type: workoutType,
                user: nil,
                createdBy: nil
            )
        }
    }
}
