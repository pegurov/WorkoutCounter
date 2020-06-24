import UIKit
import Firebase

final class WorkoutTypeCoordinator: StoryboardCoordinator<WorkoutTypeListViewController> {

    // MARK: - Output -
    var onFinish: ((_ object: ActivityType) -> Void)? {
        didSet { rootViewController.onObjectSelected = onFinish }
    }

    // MARK: - StoryboardCoordinator -
    override func configureRootViewController(
        _ controller: WorkoutTypeListViewController) {
        
        controller.onPrepareForSegue = { [weak self] segue, _ in
            if let createVC = segue.destination as? WorkoutTypeCreateViewController {
                self?.configureCreateViewController(createVC)
            }
        }
    }
    
    private func configureCreateViewController(_ controller: WorkoutTypeCreateViewController) {
        
        controller.onFinish = { [weak self, weak controller] title in
            if let title = title, !title.isEmpty {
                
                controller?.showProgressHUD()
                let newWorkoutType = FirebaseData.ActivityType(
                    title: title,
                    createdAt: Date(),
                    createdBy: Auth.auth().currentUser?.uid ?? ""
                )
                Firestore.firestore().upload(object: newWorkoutType) { result in
                    controller?.hideProgressHUD()
                    
                    switch result {
                    case let .success(createdType):
                        self?.onFinish?(ActivityType(firebaseData: createdType.1, remoteId: createdType.0))
                    case .failure:
                        break
// TODO: -
                    }
                }
            }
        }
    }
}
