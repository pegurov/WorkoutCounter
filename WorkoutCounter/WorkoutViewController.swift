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
// TODO: -
//        guard !existingTypes.contains(where: { $0 == type.remoteId }) else { return }
//
//        let newActivity = FirebaseData.Activity(
//            type: type.remoteId,
//            user: userId,
//            createdAt: Date(),
//            workout: workoutId
//        )
//        self?.navigationController?.showProgressHUD()
//        Firestore.firestore().upload(object: newActivity) { result in
//            switch result {
//            case .success: break
//            case .failure:
//                break
//// TODO: - Handle errors
//            }
//            self?.navigationController?.hideProgressHUD()
//            self?.activityTypeCoordinator = nil
//        }
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
// TODO: -
        
//        let newSet = FirebaseData.Workout.Session.Set(count: count, createdAt: Date())
//        Firestore.firestore().upload(object: newSet) { result in
//            switch result {
//            case .success:
//                break
//            case .failure:
//                break
//// TODO: - handle error
//            }
//        }
    }
    
    // MARK: - Getting all the data
    private var workout: (String, FirebaseData.Workout)?
    private var activities: [String: FirebaseData.Activity] = [:] // [activityId: Activity]
    private var user: (String, FirebaseData.User)?
    
    private func subscribeToUpdates() {
//        guard workoutSubscription == nil else { return }
//
//        let userId: String
//        let date: Date
//
//        switch mode! {
//        case let .today(currentUserId):
//            userId = currentUserId
//            date = Date()
//        case let .other(workout):
//            userId = workout.createdBy
//            date = workout.createdAt
//        }
//
//// TODO: - Можно вырубать сеть и пытаться сразу показать из кеша
//
//        // 1. Получаем workout
//        // 2. Получаем goals
//        // 3. Получаем активности
//        // 4. Получаем все типы для (активностей + goals)
//        // 5. (only if mode = current) Добавляем автоматически все активности которые есть в goals, но нет в активностях.
//            // если мы досоздали активности - гораздо проще просто заново переподписаться на весь стек сверху
//        // 6. Получаем все sets по всем активностям
//        // 7. Строим data source, форвардим его в activities list, там делаем reloadData на получение, все
//
//        unsubscribeFromEverything()
//        workout = nil
//        getOrCreateWorkoutWith(userId: userId, date: date) { [weak self] workoutId, workout in
//            self?.workout = (workoutId, workout)
//            self?.unsubscribeFromUpdates(to: [.activities, .goals, .types, .sets])
//            self?.activities = []
//            self?.getActivities(workoutId: workoutId) { activitiesTypes in
//                self?.unsubscribeFromUpdates(to: [.goals, .types, .sets])
//                self?.goals = [:]
//                self?.getGoals(userId: userId) { goalsTypes in
//                    self?.unsubscribeFromUpdates(to: [.types, .sets])
//                    self?.types = [:]
//                    self?.getTypes(ids: activitiesTypes + goalsTypes) {
//                        self?.addActivitiesFromGoalsIfNeeded(userId: userId, workoutId: workoutId) { hasAddedNewActivities in
//                            if hasAddedNewActivities {
//                                self?.subscribeToUpdates()
//                            } else {
//                                self?.unsubscribeFromUpdates(to: [.sets])
//                                self?.sets = [:]
//                                self?.getSets(activitiesIds: (self?.activities.map{ $0.0 }) ?? []) {
//                                    self?.buildDataSource()
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
//    // MARK: - Private
//    private func getOrCreateWorkoutWith(userId: String, date: Date, completion: @escaping (String, FirebaseData.Workout) -> ()) {
//// TODO: - кажется что если уже есть workoutId, то надо получать по нему прям а не по дате + user id
//        workoutSubscription = Firestore.firestore().getObjects(
//            query: { $0.whereField("createdBy", isEqualTo: userId).whereField("createdAt", isTheSameDayAs: date) },
//            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Workout)], Error>) in
//                switch result {
//                case let .success(workouts):
//                    if let (existingWorkoutId, workout) = workouts.first {
//                        completion(existingWorkoutId, workout)
//                    } else {
//                        self?.makeWorkout(userId: userId) { _, _ in
//                            self?.subscribeToUpdates()
//                        }
//                    }
//                case .failure:
//                    break
//// TODO: - handle error
//                }
//            }
//        )
//
//    }
//
//    private func makeWorkout(userId: String, completion: @escaping (String, FirebaseData.Workout) -> ()) {
//        unsubscribeFromEverything()
//        let newWorkout = FirebaseData.Workout(createdBy: userId, createdAt: Date())
//        Firestore.firestore().upload(object: newWorkout) { result in
//            switch result {
//            case let .success(id, workout):
//                completion(id, workout)
//            case .failure:
//                break
//// TODO: - handle error
//            }
//        }
//    }
//
//    private func getActivities(workoutId: String, completion: @escaping ([String]) -> ()) {
//        activitiesSubscription = Firestore.firestore().getObjects(
//            query: { $0.whereField("workout", isEqualTo: workoutId).order(by: "createdAt", descending: true) },
//            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Activity)], Error>) in
//                switch result {
//                case let .success(activities):
//                    self?.activities = activities
//                    completion(activities.map { $1.type })
//                case .failure:
//                    break
//// TODO: - handle error
//                }
//            }
//        )
//    }
//
//    private func getGoals(userId: String, completion: @escaping ([String]) -> ()) {
//        goalsSubscription = Firestore.firestore().getObjects(
//            query: { $0.whereField("user", isEqualTo: userId).order(by: "createdAt") },
//            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.User.Goal)], Error>) in
//                switch result {
//                case let .success(goals):
//                    goals.forEach { self?.goals[$0.0] = $0.1 }
//                    completion(goals.map { $1.type })
//                case .failure:
//                    break
//// TODO: - handle error
//                }
//            }
//        )
//    }
//
//    private func getTypes(ids: [String], completion: @escaping () -> ()) {
//        if ids.isEmpty { completion(); return }
//
//        let counter = Counter()
//        ids.forEach { id in
//            counter.increment()
//            typesSubscriptions.append(Firestore.firestore().getObject(id: id) { [weak self] (result: Result<(String, FirebaseData.Activity), Error>) in
//                switch result {
//                case let .success(id, type):
//                    self?.types[id] = type
//                case .failure:
//// TODO: - Handle error
//                    break
//                }
//                counter.decrement {
//                    completion()
//                }
//            })
//        }
//    }
//
//    private func addActivitiesFromGoalsIfNeeded(userId: String, workoutId: String, completion: @escaping (Bool) -> ()) {
//        if goals.keys.isEmpty { completion(false); return }
//
//        switch mode! {
//        case .today:
//            var hasAdded: Bool = false
//            let counter = Counter()
//            goals.values.forEach { goal in
//                if activities.first(where: { activity in
//                    activity.1.type == goal.type
//                }) == nil {
//                    unsubscribeFromEverything()
//                    hasAdded = true
//                    counter.increment()
//                    let newActivity = FirebaseData.Activity(
//                        type: goal.type,
//                        user: userId,
//                        createdAt: Date(),
//                        workout: workoutId
//                    )
//                    Firestore.firestore().upload(object: newActivity) { result in
//                        switch result {
//                        case .success:
//                            hasAdded = true
//                        case .failure:
//// TODO: - Handle error
//                            break
//                        }
//                        counter.decrement {
//                            completion(hasAdded)
//                        }
//                    }
//                }
//            }
//            if !hasAdded {
//                completion(false)
//            }
//        case .other:
//            completion(false)
//        }
//    }
//
//    private func getSets(activitiesIds: [String], completion: @escaping () -> ()) {
//        guard !activitiesIds.isEmpty else { completion(); return }
//
//        let counter = Counter()
//        activitiesIds.forEach { activityId in
//            counter.increment()
//            setsSubscriptions.append(Firestore.firestore().getObjects(
//                query: { $0.whereField("activity", isEqualTo: activityId).order(by: "createdAt") },
//                onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Set)], Error>) in
//                    switch result {
//                    case let .success(incomingSets):
//                        self?.sets[activityId] = incomingSets
//                    case .failure:
//                        break
//// TODO: - handle error
//                    }
//                    counter.decrement {
//                        completion()
//                    }
//                }
//            ))
//        }
//    }
    
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
