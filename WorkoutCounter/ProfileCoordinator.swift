import UIKit
import Firebase

// чтобы цель можно было удалить через detail
// а так же отредактировать
// 2. надо сделать так, чтобы нельзя было выбрать в цель повторно одно и то-же
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
        controller.onPrepareForSegue = { [weak self, userId] segue, sender in
            if segue.identifier == SegueId.create.rawValue,
                let destination = segue.destination as? GoalViewController
            {
                self?.configureGoal(controller: destination, userId: userId)
            }
        }
    }
    
    private func configureGoal(controller: GoalViewController, userId: String) {
        controller.onAddTap = { [weak self] type, count in
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
        controller.onSelectTypeTap = { [weak weakController = controller, weak self] in
            guard let strongController = weakController else { return }
            self?.showSelectType(from: strongController)
        }
    }
    
    // MARK: - Starting select type
    private func showSelectType(from controller: GoalViewController) {
        
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
