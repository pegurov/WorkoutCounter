import UIKit
import Firebase

// чтобы можно было просматривать чужой профиль
//  - отключены: кнопка добавления, кнопка выйти и нажатие на ячейку в таблице

final class ProfileCoordinator: StoryboardCoordinator<ProfileViewController> {
    
    // MARK: - Private
    let userId: String
    var activitiesCoordinator: ActivitiesCoordinator?
    
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
            let sender: (User.Goal?, User) = (goal, user)
            controller?.performSegue(withIdentifier: SegueId.detail.rawValue, sender: sender)
        }
        controller.onAddGoal = { [weak controller = controller] user in
            let sender: (User.Goal?, User) = (nil, user)
            controller?.performSegue(withIdentifier: SegueId.detail.rawValue, sender: sender)
        }
        controller.onPrepareForSegue = { [weak self] segue, sender in
            if let destination = segue.destination as? GoalViewController {
                if let (goal, user) = sender as? (User.Goal?, User) {
                    self?.configureGoal(controller: destination, user: user, goal: goal)
                }
            }
        }
    }
    
    private func configureGoal(controller: GoalViewController, user: User, goal: User.Goal?) {
        controller.goal = goal
        controller.user = user
        
        controller.onSelectActivityTap = { [weak weakController = controller, weak self] in
            
            self?.showSelectActivity { newActivity in
                guard let strongController = weakController else { return }
                
                strongController.activity = newActivity
                self?.navigationController?.popToViewController(strongController, animated: true)
            }
        }
        controller.onFinish = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Starting select activity
    private func showSelectActivity(completion: @escaping (Activity) -> ()) {
        
        activitiesCoordinator = ActivitiesCoordinator(
            storyboard: .activities,
            startInNavigation: false
        )
        activitiesCoordinator?.onFinish = { [weak self] activity in
            completion(activity)
            self?.activitiesCoordinator = nil
        }
        navigationController?.pushViewController(
            activitiesCoordinator!.rootViewController,
            animated: true
        )
    }
}
