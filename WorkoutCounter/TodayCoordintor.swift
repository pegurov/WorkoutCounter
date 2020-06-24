import UIKit
import Firebase

final class TodayCoordinator: StoryboardCoordinator<WorkoutViewController> {

    private let userId: String
    private var activityTypeCoordinator: WorkoutTypeCoordinator?
    
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
        controller.onAddActivity = { [weak self, userId] workoutId, existingTypes in
            self?.chooseActivityType { type in
                self?.navigationController?.popToRootViewController(animated: true)
                guard !existingTypes.contains(where: { $0 == type.remoteId }) else { return }
                
                let newActivity = FirebaseData.Activity(
                    type: type.remoteId,
                    user: userId,
                    createdAt: Date(),
                    workout: workoutId
                )
                self?.navigationController?.showProgressHUD()
                Firestore.firestore().upload(object: newActivity) { result in
                    switch result {
                    case .success: break
                    case .failure:
                        break
// TODO: - Handle errors
                    }
                    self?.navigationController?.hideProgressHUD()
                    self?.activityTypeCoordinator = nil
                }
            }
        }
    }
    
    private func chooseActivityType(completion: @escaping (ActivityType) -> ()) {
        activityTypeCoordinator = WorkoutTypeCoordinator(storyboard: .workoutType, startInNavigation: false)
        activityTypeCoordinator?.onFinish = completion
        
        guard let root = activityTypeCoordinator?.rootViewController else { assertionFailure(); return }
        navigationController?.pushViewController(root, animated: true)
    }
}
