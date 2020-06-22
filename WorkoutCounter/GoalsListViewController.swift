import Firebase
import UIKit

// Так чего хочется
// Чтобы можно было описать список как
// 1. тип сущности + опционально qeury
// 2. Graph, по которому нужно зарезолвить все dependencies
// 3. Чтобы dataSource собирался из этого всего автоматически и наружу торчал только он.
// При любых изменениях всех отображаемых данных они должны автоматом долетать до клиента
// dataSource перегенерироваться и долетать до view controller
// Чтобы можно было отписаться и подписаться на все зависимости при уходе/приходе на экран

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
    var mainData: [Any] = []
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
                    let goals: [FirebaseData.Goal] = value.map { $0.1 }
                    self?.mainData = goals
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
            listeners.append(Firestore.firestore().getObject(id: id) { [weak self] (result: Result<(String, FirebaseData.WorkoutType), Error>) in
                switch result {
                case let .success(id, type):
                    var types: [String: Any] = self?.dependenciesContainer["types"] ?? [:]
                    types[id] = type
                    self?.dependenciesContainer["types"] = types
                case .failure:
// TODO: - Handle error
                    break
                }
                counter.decrement()
                if counter.isReady {
                    self?.makeDataSource()
                }
            })
        }
    }
    
    private func makeDataSource() {
        guard let goals = mainData as? [FirebaseData.Goal] else { return }
        guard let types = dependenciesContainer["types"] as? [String: FirebaseData.WorkoutType] else { return }
        
        dataSource = goals.map {
            let workoutType: WorkoutType?
            if let firebaseData = types[$0.type] {
                workoutType = WorkoutType(
                    firebaseData: firebaseData,
                    remoteId: $0.type,
                    createdBy: nil
                )
            } else {
                workoutType = nil
            }
            return Goal(
                firebaseData: $0,
                type: workoutType,
                user: nil,
                createdBy: nil
            )
        }
        tableView.reloadData()
    }
}
