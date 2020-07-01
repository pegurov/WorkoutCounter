import UIKit
import Firebase

final class TodayCoordinator: StoryboardCoordinator<WorkoutViewController> {

    private let userId: String
    private var activitiesCoordinator: ActivitiesCoordinator?
    
    init(
        storyboard: UIStoryboard,
        startInNavigation: Bool = true,
        userId: String)
    {
        self.userId = userId
        super.init(storyboard: storyboard, startInNavigation: startInNavigation)
    }
    
    // MARK: - StoryboardCoordinator -
    override func configureRootViewController(_ controller: WorkoutViewController) {
        controller.mode = .today(userId)
        controller.onAddSession = { [weak self, weak controller] in
            self?.chooseActivity { activity in
                self?.navigationController?.popToRootViewController(animated: true)
                controller?.addSession(activity: activity)
            }
        }
        controller.onPrepareForSegue = { [weak self] segue, sender in
            if
                let detail = segue.destination as? SetListViewController,
                let (workout, sessionIndex) = sender as? (Workout, Int)
            {
                self?.configureSetList(controller: detail, workout: workout, sessionIndex: sessionIndex)
            } else {
                assertionFailure()
            }
        }
    }
    
    private func chooseActivity(completion: @escaping (Activity) -> ()) {
        activitiesCoordinator = ActivitiesCoordinator(storyboard: .activities, startInNavigation: false)
        activitiesCoordinator?.onFinish = { [weak self] activity in
            completion(activity)
            self?.activitiesCoordinator = nil
        }
        
        guard let root = activitiesCoordinator?.rootViewController else { assertionFailure(); return }
        navigationController?.pushViewController(root, animated: true)
    }
    
    private func configureSetList(controller: SetListViewController, workout: Workout, sessionIndex: Int) {
        controller.workout = workout
        controller.sessionIndex = sessionIndex
    }
}

final class WorkoutCoordinator: StoryboardCoordinator<WorkoutViewController> {

    private let workout: Workout
    
    init(
        storyboard: UIStoryboard,
        startInNavigation: Bool = true,
        workout: Workout)
    {
        self.workout = workout
        super.init(storyboard: storyboard, startInNavigation: startInNavigation)
    }
    
    // MARK: - StoryboardCoordinator -
    override func configureRootViewController(_ controller: WorkoutViewController) {
        controller.mode = .other(workout.firebaseData)
    }
}
