import UIKit
import Firebase

final class WorkoutViewController: UIViewController {
    
    enum Mode {
        case today(String) // userId
        case other(FirebaseData.Workout)
    }
    
    // MARK: - Input
    var mode: Mode!
    func addSession(activity: Activity) {
        guard let workout = workout else { return }
        guard !((workout.1.sessions ?? []).map({ $0.activity }).contains(where: { $0 == activity.remoteId })) else { return }

        var sessions = workout.1.sessions ?? []
        sessions.append(.init(
            activity: activity.remoteId,
            createdAt: Date(),
            sets: []
        ))
        let updatedWorkout = FirebaseData.Workout(
            createdBy: workout.1.createdBy,
            createdAt: workout.1.createdAt,
            sessions: sessions
        )
        showProgressHUD()
        Firestore.firestore().upload(object: updatedWorkout, underId: workout.0) { [weak self] result in
            self?.hideProgressHUD()
// TODO: - Handle errors
        }
    }
    
    // MARK: - Output
    var onAddSession: (() -> ())?
    
    // MARK: - User actions
    @IBOutlet weak var emptyState: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func addSessionTap(_ sender: UIButton) {
        onAddSession?()
    }
    
    // MARK: - Private
    private var sessionList: SessionListViewController?
        
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
        if let destination = segue.destination as? SessionListViewController {
            destination.onObjectSelected = { [weak self] session in
                self?.showAddSetToSession(session: session)
            }
            destination.onUpdateEmptyState = { [weak self] isEmpty in
                self?.containerView.isHidden = isEmpty
                self?.emptyState.isHidden = !isEmpty
            }
            sessionList = destination
        } else {
            onPrepareForSegue?(segue, sender)
        }
    }
    
    private func showAddSetToSession(session: Workout.Session) {
        let alertController = UIAlertController(
            title: session.activity?.title ?? "",
            message: "Добавить подход",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(
            title: "Сохранить", style: .default, handler: { [weak self] alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField
            if let text = textField.text, !text.isEmpty, let intValue = Int(text) {
                self?.addSetTo(session: session, count: intValue)
            }
        })
        
        let cancelAction = UIAlertAction(
            title: "Отмена", style: .cancel, handler: { action -> Void in
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Повторений"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func addSetTo(session: Workout.Session, count: Int) {
        guard let workout = workout else { return }
        let updatedSessions: [FirebaseData.Workout.Session] = (workout.1.sessions ?? []).map {
            if session.firebaseData.activity == $0.activity {
                var newSets = $0.sets ?? []
                newSets.append(.init(count: count, createdAt: Date()))
                return .init(activity: $0.activity, createdAt: $0.createdAt, sets: newSets)
            } else {
                return $0
            }
        }
        let updatedWorkout = FirebaseData.Workout(
            createdBy: workout.1.createdBy,
            createdAt: workout.1.createdAt,
            sessions: updatedSessions
        )
        showProgressHUD()
        Firestore.firestore().upload(object: updatedWorkout, underId: workout.0) { [weak self] _ in
            self?.hideProgressHUD()
// TODO: - Handle error
        }
    }
    
    // MARK: - Getting all the data
    private var workout: (String, FirebaseData.Workout)?
    private var activities: [String: FirebaseData.Activity] = [:] // [activityId: Activity]
    private var user: (String, FirebaseData.User)?
    
    private func subscribeToUpdates() {
        guard workoutSubscription == nil else { return }

        let userId: String
        let date: Date

        switch mode! {
        case let .today(currentUserId):
            userId = currentUserId
            date = Date()
        case let .other(workout):
            userId = workout.createdBy
            date = workout.createdAt
        }

// TODO: - Можно вырубать сеть и пытаться сразу показать из кеша

        // 1. Получаем workout
        // 2. Получаем user
        // 3. (only if mode = current) Добавляем автоматически все sessions по активностям которые есть в goals
        // если мы досоздали активности - гораздо проще просто заново переподписаться на весь стек сверху
        // 4. Получаем все типы для workout.sessions
        
        // 7. Строим data source, форвардим его в activities list, там делаем reloadData на получение, все

        unsubscribeFromEverything()
        workout = nil
        getOrCreateWorkoutWith(userId: userId, date: date) { [weak self] workoutId, workout in
            self?.workout = (workoutId, workout)
            self?.unsubscribeFromUpdates(to: [.user, .activities])
            self?.user = nil
            self?.getUser(userId: userId) { userId, user in
                self?.user = (userId, user)
                self?.addSessionsFromGoalsIfNeeded { hasAdded in
                    if hasAdded {
                        self?.unsubscribeFromEverything()
                        self?.subscribeToUpdates()
                    } else {
                        self?.unsubscribeFromUpdates(to: [.activities])
                        self?.getAllNeededActivities {
                            self?.buildDataSource()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    private func getOrCreateWorkoutWith(userId: String, date: Date, completion: @escaping (String, FirebaseData.Workout) -> ()) {
// TODO: - кажется что если уже есть workoutId, то надо получать по нему прям а не по дате + user id
        workoutSubscription = Firestore.firestore().getObjects(
            query: { $0.whereField("createdBy", isEqualTo: userId).whereField("createdAt", isTheSameDayAs: date) },
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Workout)], Error>) in
                switch result {
                case let .success(workouts):
                    if let (existingWorkoutId, workout) = workouts.first {
                        completion(existingWorkoutId, workout)
                    } else {
                        self?.makeWorkout(userId: userId) { _, _ in
                            self?.subscribeToUpdates()
                        }
                    }
                case .failure:
                    break
// TODO: - handle error
                }
            }
        )

    }

    private func makeWorkout(userId: String, completion: @escaping (String, FirebaseData.Workout) -> ()) {
        unsubscribeFromEverything()
        let newWorkout = FirebaseData.Workout(createdBy: userId, createdAt: Date(), sessions: [])
        Firestore.firestore().upload(object: newWorkout) { result in
            switch result {
            case let .success(id, workout):
                completion(id, workout)
            case .failure:
                break
// TODO: - handle error
            }
        }
    }
    
    private func getUser(userId: String, completion: @escaping (String, FirebaseData.User) -> ()) {
        userSubscription = Firestore.firestore().getObject(id: userId) { (result: Result<(String, FirebaseData.User), Error>) in
            switch result {
            case let .success(data):
                completion(data.0, data.1)
            case .failure:
                break
// TODO: - handle error
            }
        }
    }
    
    private func getAllNeededActivities(completion: @escaping () -> ()) {
        guard let workout = workout?.1 else { completion(); assertionFailure(); return }
        let idsToGet: [String] = (workout.sessions?.map{ $0.activity }) ?? []
        guard !idsToGet.isEmpty else { completion(); return }

        let counter = Counter()
        idsToGet.forEach { id in
            counter.increment()
            activitiesSubscriptions.append(Firestore.firestore().getObject(id: id) { [weak self] (result: Result<(String, FirebaseData.Activity), Error>) in
                switch result {
                case let .success(id, type):
                    self?.activities[id] = type
                case .failure:
// TODO: - Handle error
                    break
                }
                counter.decrement {
                    completion()
                }
            })
        }
    }

    private func addSessionsFromGoalsIfNeeded(completion: @escaping (Bool) -> ()) {
        guard let user = user?.1 else { completion(false); assertionFailure(); return }
        guard let goals = user.goals else { completion(false); assertionFailure(); return }
        guard let workout = workout?.1 else { completion(false); assertionFailure(); return }
        guard let workoutRemoteId = self.workout?.0 else { completion(false); assertionFailure(); return }
        
        switch mode! {
        case .today:
            var sessionsToAdd: [FirebaseData.Workout.Session] = []
            goals.forEach { goal in
                if workout.sessions?.first(where: { session in
                    session.activity == goal.activity
                }) == nil
                {
                    unsubscribeFromEverything()
                    sessionsToAdd.append(
                        FirebaseData.Workout.Session(
                            activity: goal.activity,
                            createdAt: Date(),
                            sets: []
                        )
                    )
                }
            }
            if sessionsToAdd.count > 0 {
                var updatedSessions = workout.sessions ?? []
                updatedSessions.append(contentsOf: sessionsToAdd)
                let updatedWorkout = FirebaseData.Workout(
                    createdBy: workout.createdBy,
                    createdAt: workout.createdAt,
                    sessions: updatedSessions
                )
                Firestore.firestore().upload(object: updatedWorkout, underId: workoutRemoteId) { _ in
                    completion(true)
// TODO: - Handle error
                }
            } else {
                completion(false)
            }
        case .other:
            completion(false)
        }
    }
    
    // MARK: - Managing subscriptions
    enum Subscription: Hashable {
        case workout
        case user
        case activities
    }
    
    private var workoutSubscription: ListenerRegistration?
    private var userSubscription: ListenerRegistration?
    private var activitiesSubscriptions: [ListenerRegistration] = []
    
    private func unsubscribeFromEverything() {
        unsubscribeFromUpdates(to: [.workout, .user, .activities])
    }
    
    private func unsubscribeFromUpdates(to subscriptions: Set<Subscription>) {
  
        subscriptions.forEach {
            switch $0 {
            case .workout:
                workoutSubscription?.remove()
                workoutSubscription = nil
            case .user:
                userSubscription?.remove()
                userSubscription = nil
            case .activities:
                activitiesSubscriptions.forEach { $0.remove() }
                activitiesSubscriptions = []
            }
        }
    }
        
    // MARK: - Building the data source
    private func buildDataSource() {
        hideProgressHUD()
        guard let workout = workout?.1 else { return }
            
        sessionList?.dataSource = (workout.sessions ?? []).map { sessionData in
            Workout.Session(
                firebaseData: sessionData,
                activity: makeActivity(id: sessionData.activity),
                goal: makeGoal(activityId: sessionData.activity)
            )
        }
    }
    
    private func makeActivity(id: String) -> Activity? {
        guard let data = activities[id] else { assertionFailure(); return nil }
        return Activity(firebaseData: data, remoteId: id, createdBy: nil)
    }
    
    private func makeGoal(activityId: String) -> User.Goal? {
        guard let user = user?.1 else { assertionFailure(); return nil }
        guard let goal = (user.goals ?? []).first(where: { $0.activity == activityId }) else { return nil }
        
        return User.Goal(
            firebaseData: goal,
            activity: makeActivity(id: activityId)
        )
    }
}

extension Query {
    
    func whereField(_ field: String, isTheSameDayAs date: Date) -> Query {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard
            let start = Calendar.current.date(from: components),
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)
        else {
            fatalError("Could not find start date or calculate end date.")
        }
        return
            whereField(field, isGreaterThan: start.timeIntervalSince1970)
                .whereField(field, isLessThan: end.timeIntervalSince1970)
    }
}
