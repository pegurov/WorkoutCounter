import UIKit
import Firebase

final class ActivitiesCoordinator: StoryboardCoordinator<ActivityListViewController> {

    // MARK: - Output -
    var onFinish: ((_ object: Activity) -> Void)? {
        didSet { rootViewController.onObjectSelected = onFinish }
    }

    // MARK: - StoryboardCoordinator -
    override func configureRootViewController(_ controller: ActivityListViewController) {
        
        controller.onPrepareForSegue = { [weak self] segue, _ in
            if let createVC = segue.destination as? ActivityCreateViewController {
                self?.configureCreateViewController(createVC)
            }
        }
    }
    
    private func configureCreateViewController(_ controller: ActivityCreateViewController) {
        
        controller.onFinish = { [weak self, weak controller] title in
            if let title = title, !title.isEmpty {
                
                controller?.showProgressHUD()
                let newWorkoutType = FirebaseData.Activity(
                    title: title,
                    createdAt: Date(),
                    createdBy: Auth.auth().currentUser?.uid ?? ""
                )
                Firestore.firestore().upload(object: newWorkoutType) { result in
                    controller?.hideProgressHUD()
                    
                    switch result {
                    case let .success(createdType):
                        self?.onFinish?(Activity(firebaseData: createdType.1, remoteId: createdType.0))
                    case .failure:
                        break
// TODO: -
                    }
                }
            }
        }
    }
}
