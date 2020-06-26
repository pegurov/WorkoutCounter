import UIKit
import Firebase

final class FeedViewController: UITableViewController {
    
    // MARK: - Private impl
    private var sections: [(String, [Workout])] = []
    
    deinit { unsubscribeFromEverything() }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showProgressHUD()
        subscribeToUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeToUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromEverything()
    }
    
    // MARK: - NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        onPrepareForSegue?(segue, sender)
    }
    
    // MARK: - Getting all the data
    private var workouts: [(String, FirebaseData.Workout)] = []
    private var users: [String: FirebaseData.User] = [:]
    private var activities: [String: FirebaseData.Activity] = [:]
    
    private func subscribeToUpdates() {
        guard workoutsSubscription == nil else { return }
        
        unsubscribeFromEverything()
        workouts = []
        showProgressHUD()
        getWorkouts { [weak self] in
            self?.unsubscribeFromUpdates(to: [.users, .activities])
            self?.users = [:]
            self?.getUsers {
                self?.unsubscribeFromUpdates(to: [.activities])
                self?.activities = [:]
                self?.getActivities {
                    self?.hideProgressHUD()
                    self?.buildDataSource()
                }
            }
        }
    }
    
    private func getWorkouts(completion: @escaping () -> ()) {
        workoutsSubscription = Firestore.firestore().getObjects(
            query: { $0.order(by: "createdAt", descending: true).limit(to: 40) },
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Workout)], Error>) in
                switch result {
                case let .success(data):
                    self?.workouts = data
                case .failure:
                    break
// TODO: - Handle error
                }
                completion()
            }
        )
    }
    
    private func getUsers(completion: @escaping () -> ()) {
        let ids = workouts.map { $0.1.createdBy }
        guard !ids.isEmpty else { completion(); return }
        
        let counter = Counter()
        ids.forEach { userId in
            counter.increment()
            usersSubscriptions.append(
                Firestore.firestore().getObject(id: userId, completion: { [weak self] (result: Result<(String, FirebaseData.User), Error>) in
                    switch result {
                    case let .success(data):
                        self?.users[data.0] = data.1
                    case .failure:
                        break
// TODO: - Handle error
                    }
                    counter.decrement {
                        completion()
                    }
                })
            )
        }
    }
    
    private func getActivities(completion: @escaping () -> ()) {
        let ids = workouts.flatMap { ($0.1.sessions ?? []).map { $0.activity } }
        guard !ids.isEmpty else { completion(); return }
        
        let counter = Counter()
        ids.forEach { activityId in
            counter.increment()
            activitiesSubscriptions.append(
                Firestore.firestore().getObject(id: activityId, completion: { [weak self] (result: Result<(String, FirebaseData.Activity), Error>) in
                    switch result {
                    case let .success(data):
                        self?.activities[data.0] = data.1
                    case .failure:
                        break
// TODO: - Handle error
                    }
                    counter.decrement {
                        completion()
                    }
                })
            )
        }
    }
    
    // MARK: - Managing subscriptions
    enum Subscription: Hashable {
        case workouts
        case users
        case activities
    }
    
    private var workoutsSubscription: ListenerRegistration?
    private var usersSubscriptions: [ListenerRegistration] = []
    private var activitiesSubscriptions: [ListenerRegistration] = []
    
    private func unsubscribeFromEverything() {
        unsubscribeFromUpdates(to: [.workouts, .users, .activities])
    }
    
    private func unsubscribeFromUpdates(to subscriptions: Set<Subscription>) {

        subscriptions.forEach {
            switch $0 {
            case .workouts:
                workoutsSubscription?.remove()
                workoutsSubscription = nil
            case .users:
                usersSubscriptions.forEach { $0.remove() }
                usersSubscriptions = []
            case .activities:
                activitiesSubscriptions.forEach { $0.remove() }
                activitiesSubscriptions = []
            }
        }
    }
        
    // MARK: - Building the data source
    private func buildDataSource() {
        let allWorkouts: [Workout] = workouts.map { workout in
            Workout(
                firebaseData: workout.1,
                remoteId: workout.0,
                createdBy: makeUser(id: workout.1.createdBy),
                sessions: (workout.1.sessions ?? []).map { session in
                    Workout.Session(
                        firebaseData: session,
                        activity: makeActivity(id: session.activity),
                        goal: makeUser(id: workout.1.createdBy)?.goals.first(where: { $0.firebaseData.activity == session.activity })
                    )
                }
            )
        }
        sections = allWorkouts.reduce([], { partialResult, workout in
            if let lastSection = partialResult.last, let lastWorkout = lastSection.1.last {
                if Calendar.current.isDate(workout.createdAt, inSameDayAs: lastWorkout.createdAt) {
                    var newWorkouts = lastSection.1
                    newWorkouts.append(workout)
                    var newSection = lastSection
                    newSection.1 = newWorkouts
                    var newSections = partialResult
                    _ = newSections.popLast()
                    newSections.append(newSection)
                    return newSections
                } else {
                    var newResult = partialResult
                    newResult.append((workout.createdAt.workoutTitle, [workout]))
                    return newResult
                }
            } else {
                return [(workout.createdAt.workoutTitle, [workout])]
            }
        })
        tableView.reloadData()
    }
  
    private func makeUser(id: String) -> User? {
        guard let user = users[id] else { assertionFailure(); return nil }
        return User(
            firebaseData: user,
            remoteId: id
        )
    }

    private func makeActivity(id: String) -> Activity? {
        guard let activity = activities[id] else { assertionFailure(); return nil }
        return Activity(
            firebaseData: activity,
            remoteId: id,
            createdBy: makeUser(id: activity.createdBy)
        )
    }
    
    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        let workout = sections[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = workout.createdBy?.name ?? workout.createdBy?.remoteId
        cell.detailTextLabel?.text = workout.feedDescription
        return cell
    }
}

final class WorkoutCell: UITableViewCell { }

extension Workout {
    
    var feedDescription: String {
        var result = sessions.reduce(""){ partialResult, session in
            let totalCount = session.sets.reduce(0, { $0 + $1.count })
            let goalEnding: String
            if let goal = session.goal {
                goalEnding = "/\(goal.count)"
            } else {
                goalEnding = ""
            }
            
            return partialResult + "\(session.activity?.title ?? "") : \(session.shortSetsDescription)\n"
        }
        _ = result.popLast()
        return result
    }
}

extension Date {
    
    private static let formatter: DateFormatter = {
        let value = DateFormatter()
        value.dateStyle = .long
        value.timeStyle = .none
        value.doesRelativeDateFormatting = true
        return value
    }()
    
    var workoutTitle: String {
        return Date.formatter.string(from: self)
    }
}
