import UIKit
import Firebase

final class ProfileCoordinator: StoryboardCoordinator<ProfileViewController> {
    
    // MARK: - Private
    let userId: String
    let user: User
    var selectTypeCoordinator: WorkoutTypeCoordinator?
    
    // MARK: - Init
    init(
        storyboard: UIStoryboard,
        startInNavigation: Bool = true,
        userId: String,
        user: User)
    {
        self.userId = userId
        self.user = user
        super.init(storyboard: storyboard, startInNavigation: startInNavigation)
    }
    
    // MARK: - Output
    var onLogout: (() -> Void)? {
        get { return rootViewController.onLogout }
        set { rootViewController.onLogout = newValue }
    }
    
    override func configureRootViewController(_ controller: ProfileViewController) {
        controller.userId = userId
        controller.userName = user.name
        controller.onPrepareForSegue = { [weak self, userId] segue, sender in
            if segue.identifier == SegueId.create.rawValue,
                let destination = segue.destination as? GoalCreateViewController
            {
                destination.onAddTap = { type, count in
                    let newGoal = FirebaseData.Goal(
                        count: count,
                        type: type.remoteId,
                        user: userId,
                        createdAt: Date(),
                        createdBy: userId
                    )
                    self?.navigationController?.showProgressHUD()
                    Firestore.firestore().upload(object: newGoal) { result in
                        self?.navigationController?.hideProgressHUD()
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
                destination.onSelectTypeTap = { [weak weakDestination = destination] in
                    guard let strongDestination = weakDestination else { return }
                    self?.showSelectType(from: strongDestination)
                }
            }
        }
    }
    
    // MARK: - Starting select type
    private func showSelectType(from controller: GoalCreateViewController) {
        
        selectTypeCoordinator = WorkoutTypeCoordinator(
            storyboard: .workoutType,
            startInNavigation: false
        )
        selectTypeCoordinator?.onFinish = { [weak self, weak controller] workoutType in
            guard let controller = controller else { return }

            controller.type = workoutType
            self?.navigationController?.popToViewController(
                controller,
                animated: true
            )
        }
//        if let selectedType = selectedType {
//            selectTypeCoordinator?.selectedTypeId = selectedType.objectID
//        }
        navigationController?.pushViewController(
            selectTypeCoordinator!.rootViewController,
            animated: true
        )
    }
}
