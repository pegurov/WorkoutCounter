import UIKit
import Firebase

final class WorkoutViewController: UIViewController {
    
    enum Mode {
        case today(String) // userId
        case other(FirebaseData.Workout)
    }
    
    // MARK: - Input
    var mode: Mode!
    
    // MARK: - Output
    var onAddActivity: ((_ workoutId: String, _ existingTypes: [String]) -> ())?
    
    // MARK: - User actions
    @IBOutlet weak var emptyState: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func addActivityTap(_ sender: UIButton) {
        guard let workout = workout else { assertionFailure(); return }
        onAddActivity?(workout.0, types.keys.map{ $0 })
    }
    
    // MARK: - Private
    private var activitiesList: ActivitiesListViewController?
        
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
        if let destination = segue.destination as? ActivitiesListViewController {
            destination.onObjectSelected = { [weak self] activity in
                self?.showAddSetToActivity(activity: activity)
            }
            destination.onUpdateEmptyState = { [weak self] isEmpty in
                self?.containerView.isHidden = isEmpty
                self?.emptyState.isHidden = !isEmpty
            }
            activitiesList = destination
        } else {
            onPrepareForSegue?(segue, sender)
        }
    }
    
    private func showAddSetToActivity(activity: Activity) {
        let alertController = UIAlertController(
            title: "Повторений", message: nil, preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(
            title: "Сохранить", style: .default, handler: { [weak self] alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField
            if let text = textField.text, !text.isEmpty, let intValue = Int(text) {
                self?.addSetToActivity(activity, count: intValue)
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
    
    private func addSetToActivity(_ activity: Activity, count: Int) {
        let newSet = FirebaseData.Set(count: count, createdAt: Date(), activity: activity.remoteId)
        Firestore.firestore().upload(object: newSet) { result in
            switch result {
            case .success:
                break
            case .failure:
                break
// TODO: - handle error
            }
        }
    }
    
    // MARK: - Getting all the data
    private var activities: [(String, FirebaseData.Activity)] = []
    private var workout: (String, FirebaseData.Workout)?
    private var types: [String: FirebaseData.ActivityType] = [:] // [typeId: ActivityType]
    private var goals: [String: FirebaseData.Goal] = [:] // [goalId: Goal]
    private var sets: [String: [(String, FirebaseData.Set)]] = [:] // [activityId: [(setId, Set)]]
    
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
        // 2. Получаем goals
        // 3. Получаем активности
        // 4. Получаем все типы для (активностей + goals)
        // 5. (only if mode = current) Добавляем автоматически все активности которые есть в goals, но нет в активностях.
            // если мы досоздали активности - гораздо проще просто заново переподписаться на весь стек сверху
        // 6. Получаем все sets по всем активностям
        // 7. Строим data source, форвардим его в activities list, там делаем reloadData на получение, все
        
        unsubscribeFromEverything()
        workout = nil
        getOrCreateWorkoutWith(userId: userId, date: date) { [weak self] workoutId, workout in
            self?.workout = (workoutId, workout)
            self?.unsubscribeFromUpdates(to: [.activities, .goals, .types, .sets])
            self?.activities = []
            self?.getActivities(workoutId: workoutId) { activitiesTypes in
                self?.unsubscribeFromUpdates(to: [.goals, .types, .sets])
                self?.goals = [:]
                self?.getGoals(userId: userId) { goalsTypes in
                    self?.unsubscribeFromUpdates(to: [.types, .sets])
                    self?.types = [:]
                    self?.getTypes(ids: activitiesTypes + goalsTypes) {
                        self?.addActivitiesFromGoalsIfNeeded(userId: userId, workoutId: workoutId) { hasAddedNewActivities in
                            if hasAddedNewActivities {
                                self?.unsubscribeFromEverything()
                                self?.subscribeToUpdates()
                            } else {
                                self?.unsubscribeFromUpdates(to: [.sets])
                                self?.sets = [:]
                                self?.getSets(activitiesIds: (self?.activities.map{ $0.0 }) ?? []) {
                                    self?.buildDataSource()
                                }
                            }
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
                            self?.unsubscribeFromEverything()
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
        let newWorkout = FirebaseData.Workout(createdBy: userId, createdAt: Date())
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
    
    private func getActivities(workoutId: String, completion: @escaping ([String]) -> ()) {
        activitiesSubscription = Firestore.firestore().getObjects(
            query: { $0.whereField("workout", isEqualTo: workoutId).order(by: "createdAt", descending: true) },
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Activity)], Error>) in
                switch result {
                case let .success(activities):
                    self?.activities = activities
                    completion(activities.map { $1.type })
                case .failure:
                    break
// TODO: - handle error
                }
            }
        )
    }
    
    private func getGoals(userId: String, completion: @escaping ([String]) -> ()) {
        goalsSubscription = Firestore.firestore().getObjects(
            query: { $0.whereField("user", isEqualTo: userId) },
            onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Goal)], Error>) in
                switch result {
                case let .success(goals):
                    goals.forEach { self?.goals[$0.0] = $0.1 }
                    completion(goals.map { $1.type })
                case .failure:
                    break
// TODO: - handle error
                }
            }
        )
    }
    
    private func getTypes(ids: [String], completion: @escaping () -> ()) {
        if ids.isEmpty { completion(); return }
        
        let counter = Counter()
        ids.forEach { id in
            counter.increment()
            typesSubscriptions.append(Firestore.firestore().getObject(id: id) { [weak self] (result: Result<(String, FirebaseData.ActivityType), Error>) in
                switch result {
                case let .success(id, type):
                    self?.types[id] = type
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
    
    private func addActivitiesFromGoalsIfNeeded(userId: String, workoutId: String, completion: @escaping (Bool) -> ()) {
        if goals.keys.isEmpty {  completion(false); return }
        
        switch mode! {
        case .today:
            var hasAdded: Bool = false
            let counter = Counter()
            goals.values.forEach { goal in
                if activities.first(where: { activity in
                    activity.1.type == goal.type
                }) == nil {
                    hasAdded = true
                    showProgressHUD()
                    counter.increment()
                    let newActivity = FirebaseData.Activity(
                        type: goal.type,
                        user: userId,
                        createdAt: Date(),
                        workout: workoutId
                    )
                    Firestore.firestore().upload(object: newActivity) { result in
                        switch result {
                        case .success:
                            hasAdded = true
                        case .failure:
// TODO: - Handle error
                            break
                        }
                        counter.decrement {
                            completion(hasAdded)
                        }
                    }
                }
            }
            if !hasAdded {
                completion(false)
            }
        case .other:
            completion(false)
        }
    }
    
    private func getSets(activitiesIds: [String], completion: @escaping () -> ()) {
        guard !activitiesIds.isEmpty else { completion(); return }
        
        let counter = Counter()
        activitiesIds.forEach { activityId in
            counter.increment()
            setsSubscriptions.append(Firestore.firestore().getObjects(
                query: { $0.whereField("activity", isEqualTo: activityId) },
                onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Set)], Error>) in
                    switch result {
                    case let .success(incomingSets):
                        self?.sets[activityId] = incomingSets
                    case .failure:
                        break
// TODO: - handle error
                    }
                    counter.decrement {
                        completion()
                    }
                }
            ))
        }
    }
    
    // MARK: - Managing subscriptions
    enum Subscription: Hashable {
        case workout
        case activities
        case goals
        case types
        case sets
    }
    
    private var workoutSubscription: ListenerRegistration?
    private var activitiesSubscription: ListenerRegistration?
    private var typesSubscriptions: [ListenerRegistration] = []
    private var goalsSubscription: ListenerRegistration?
    private var setsSubscriptions: [ListenerRegistration] = []
    
    private func unsubscribeFromEverything() {
        unsubscribeFromUpdates(to: [.workout, .activities, .goals, .types, .sets])
    }
    
    private func unsubscribeFromUpdates(to subscriptions: Set<Subscription>) {
  
        subscriptions.forEach {
            switch $0 {
            case .workout:
                workoutSubscription?.remove()
                workoutSubscription = nil
            case .activities:
                activitiesSubscription?.remove()
                activitiesSubscription = nil
            case .goals:
                goalsSubscription?.remove()
                goalsSubscription = nil
            case .types:
                typesSubscriptions.forEach { $0.remove() }
                typesSubscriptions = []
            case .sets:
                setsSubscriptions.forEach { $0.remove() }
                setsSubscriptions = []
            }
        }
    }
        
    // MARK: - Building the data source
    private func buildDataSource() {
        activitiesList?.dataSource = activities.map { activityId, activityData in
            Activity(
                firebaseData: activityData,
                remoteId: activityId,
                user: nil,
                type: makeActivityType(id: activityData.type),
                workout: makeWorkout(),
                sets: makeSets(activityId: activityId),
                goal: makeGoal(activityTypeId: activityData.type)
            )
        }
        hideProgressHUD()
    }
    
    private func makeWorkout() -> Workout? {
        guard let firebaseData = self.workout else { assertionFailure(); return nil }
        return Workout(firebaseData: firebaseData.1, remoteId: firebaseData.0)
    }
    
    private func makeActivityType(id: String) -> ActivityType? {
        guard let activityTypeData = types[id] else { assertionFailure(); return nil }
        return ActivityType(firebaseData: activityTypeData, remoteId: id)
    }
    
    private func makeSets(activityId: String) -> [Activity.Set] {
        guard let setsData = sets[activityId] else { assertionFailure(); return [] }
        return setsData.map { Activity.Set(firebaseData: $0.1, remoteId: $0.0) }
    }
    
    private func makeGoal(activityTypeId: String) -> Goal? {
        guard let goal = goals.first(where: { $1.type == activityTypeId }) else { return nil }
        return Goal(
            firebaseData: goal.value,
            remoteId: goal.key,
            type: makeActivityType(id: activityTypeId),
            user: nil,
            createdBy: nil
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
