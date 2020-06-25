import UIKit
import Firebase

final class FeedViewController: UITableViewController {
    
    // MARK: - Output
    var onWorkoutSelected: ((_ workout: FirebaseData.Workout) -> ())?
    
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
    private var users: [(String, FirebaseData.User)] = []
    
    private func subscribeToUpdates() {
        guard workoutsSubscription == nil else { return }
        
        unsubscribeFromEverything()
        workouts = []
        
    }
    
    // MARK: - Managing subscriptions
    enum Subscription: Hashable {
        case workouts
        case users
    }
    
    private var workoutsSubscription: ListenerRegistration?
    private var usersSubscription: ListenerRegistration?
    
    private func unsubscribeFromEverything() {
        unsubscribeFromUpdates(to: [.workouts, .users])
    }
    
    private func unsubscribeFromUpdates(to subscriptions: Set<Subscription>) {

        subscriptions.forEach {
            switch $0 {
            case .workouts:
                workoutsSubscription?.remove()
                workoutsSubscription = nil
            case .users:
                usersSubscription?.remove()
                usersSubscription = nil
            }
        }
    }
        
    // MARK: - Building the data source
    private func buildDataSource() {
//        activitiesList?.dataSource = activities.map { activityId, activityData in
//            Activity(
//                firebaseData: activityData,
//                remoteId: activityId,
//                user: nil,
//                type: makeActivity(id: activityData.type),
//                workout: makeWorkout(),
//                sets: makeSets(activityId: activityId),
//                goal: makeGoal(activityTypeId: activityData.type)
//            )
//        }
//        hideProgressHUD()
    }
  
//    private func makeSets(activityId: String) -> [Activity.Set] {
//         Тут нет assertion, так как sets может спокойно и не быть по activity
//        guard let setsData = sets[activityId] else { return [] }
//        return setsData.map { Activity.Set(firebaseData: $0.1, remoteId: $0.0) }
//    }
}

final class WorkoutCell: UITableViewCell {
    
}
