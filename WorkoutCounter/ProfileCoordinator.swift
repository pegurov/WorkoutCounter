import UIKit
import Firebase

// чтобы можно было просматривать чужой профиль
//  - отключены: кнопка добавления, кнопка выйти и нажатие на ячейку в таблице

final class ProfileCoordinator: StoryboardCoordinator<ProfileViewController> {
    
    // MARK: - Private
    let userId: String
    var selectTypeCoordinator: WorkoutTypeCoordinator?
    
    // MARK: - Init
    init(
        storyboard: UIStoryboard,
        startInNavigation: Bool = true,
        userId: String)
    {
        self.userId = userId
        super.init(storyboard: storyboard, startInNavigation: startInNavigation)
    }
    
    // MARK: - Output
    var onLogout: (() -> Void)? {
        get { return rootViewController.onLogout }
        set { rootViewController.onLogout = newValue }
    }
    
    override func configureRootViewController(_ controller: ProfileViewController) {
        controller.userId = userId
        controller.onGoalSelected = { [weak controller = controller] goal, user in
            let sender: (Goal?, User) = (goal, user)
            controller?.performSegue(withIdentifier: SegueId.detail.rawValue, sender: sender)
        }
        controller.onAddGoal = { [weak controller = controller] user in
            let sender: (Goal?, User) = (nil, user)
            controller?.performSegue(withIdentifier: SegueId.detail.rawValue, sender: sender)
        }
        controller.onPrepareForSegue = { [weak self] segue, sender in
            if let destination = segue.destination as? GoalViewController {
                if let (goal, user) = sender as? (Goal?, User) {
                    self?.configureGoal(controller: destination, user: user, goal: goal)
                }
            }
        }
    }
    
    private func configureGoal(controller: GoalViewController, user: User, goal: Goal?) {
        controller.goal = goal
        controller.user = user
        
        controller.onSelectTypeTap = { [weak weakController = controller, weak self] in
            
            self?.showSelectType { newType in
                guard let strongController = weakController else { return }
                
                strongController.type = newType
                self?.navigationController?.popToViewController(strongController, animated: true)
                self?.selectTypeCoordinator = nil
            }
        }
        controller.onFinish = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Starting select type
    private func showSelectType(completion: @escaping (ActivityType) -> ()) {
        
        selectTypeCoordinator = WorkoutTypeCoordinator(
            storyboard: .workoutType,
            startInNavigation: false
        )
        selectTypeCoordinator?.onFinish = completion
        navigationController?.pushViewController(
            selectTypeCoordinator!.rootViewController,
            animated: true
        )
    }
}
