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
            self?.chooseActivityType { activity in
                self?.navigationController?.popToRootViewController(animated: true)
                controller?.addSession(activity: activity)
            }
        }
    }
    
    private func chooseActivityType(completion: @escaping (Activity) -> ()) {
        activitiesCoordinator = ActivitiesCoordinator(storyboard: .activities, startInNavigation: false)
        activitiesCoordinator?.onFinish = { [weak self] in
            completion($0)
            self?.activitiesCoordinator = nil
        }
        
        guard let root = activitiesCoordinator?.rootViewController else { assertionFailure(); return }
        navigationController?.pushViewController(root, animated: true)
    }
}
