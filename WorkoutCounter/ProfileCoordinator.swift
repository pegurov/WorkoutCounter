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
        controller.onPrepareForSegue = { [weak self, userId] segue, sender in
            if segue.identifier == SegueId.create.rawValue,
                let destination = segue.destination as? GoalViewController
            {
                self?.configureGoal(controller: destination, userId: userId, sender: sender)
            }
        }
        controller.onGoalSelected = { [weak controller = controller] goal in
            controller?.performSegue(withIdentifier: SegueId.create.rawValue, sender: goal)
        }
    }
    
    private func configureGoal(controller: GoalViewController, userId: String, sender: Any?) {
        
        if let goal = sender as? Goal {
            controller.goal = goal
        }
        controller.onSave = { [weak self] goal, updatedCount in
            guard let strongSelf = self else { return }
            
            self?.navigationController?.showProgressHUD()
            let updatedGoal = FirebaseData.Goal(
                count: updatedCount,
                type: goal.firebaseData.type,
                user: strongSelf.userId,
                createdAt: Date(),
                createdBy: strongSelf.userId
            )
            Firestore.firestore().upload(object: updatedGoal, underId: goal.remoteId) { result in
                self?.navigationController?.hideProgressHUD()
                switch result {
                case .success:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure:
                    break
// TODO: - Handle error
                }
            }
        }
        controller.onCreate = { [weak self] type, count in
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
                
                switch result {
                case .success:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure:
                    break
// TODO: - Handle error
                }
            }
        }
        controller.onSelectTypeTap = { [weak weakController = controller, weak self] in
            
            self?.showSelectType { newType in
                
                self?.navigationController?.showProgressHUD()
                self?.subscriptions.append(Firestore.firestore().getObjects(
                    query: {
                        $0.whereField("user", isEqualTo: userId)
                            .whereField("type", isEqualTo: newType.remoteId)
                    },
                    onUpdate: { [weak self] (result: Result<[(String, FirebaseData.Goal)], Error>) in
                        self?.navigationController?.hideProgressHUD()
                        switch result {
                        case let .success(searchResults):
                            if let (id, goal) = searchResults.first {
                                weakController?.goal = Goal(
                                    firebaseData: goal,
                                    remoteId: id,
                                    type: newType,
                                    user: nil,
                                    createdBy: nil
                                )
                            } else {
                                weakController?.goal = nil
                                weakController?.type = newType
                            }
                        case .failure:
                            break
// TODO: - Handle error
                        }
                    }
                ))
                guard let strongController = weakController else { return }
                self?.navigationController?.popToViewController(strongController, animated: true)
            }
        }
        controller.onDeleteTap = { [weak self] goalToDelete in
            self?.navigationController?.showProgressHUD()
// MOVE FIREBASE EVERYTHING
            Firestore.firestore().collection("Goal").document(goalToDelete.remoteId).delete { error in
                self?.navigationController?.hideProgressHUD()
                if let _ = error {
// TODO: - Handle error
                } else {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Starting select type
    private func showSelectType(completion: @escaping (WorkoutType) -> ()) {
        
        selectTypeCoordinator = WorkoutTypeCoordinator(
            storyboard: .workoutType,
            startInNavigation: false
        )
        selectTypeCoordinator?.onFinish = { workoutType in
            completion(workoutType)
        }
        navigationController?.pushViewController(
            selectTypeCoordinator!.rootViewController,
            animated: true
        )
    }
}
