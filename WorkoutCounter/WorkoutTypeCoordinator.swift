import UIKit
import Firebase

final class WorkoutTypeCoordinator: StoryboardCoordinator<WorkoutTypeListViewController> {

    // MARK: - Output -
    var onFinish: ((_ object: WorkoutType) -> Void)? {
        didSet { rootViewController.onObjectSelected = onFinish }
    }

    // MARK: - Input -
//    var selectedTypeId: String = "" {
//        didSet { rootViewController.selectedIds = [selectedTypeId] }
//    }
    
    // MARK: - StoryboardCoordinator -
    override func configureRootViewController(
        _ controller: WorkoutTypeListViewController) {
        
//        controller.onObjectSelected
        
//        controller.managedObjectContext = coreDataStack.managedObjectContext
//        controller.sortDescriptor = NSSortDescriptor(
//            key: "title",
//            ascending: true
//        )
//        controller.deletingEnabled = false
//        controller.onInsertNewObject = { [weak controller] in
//            controller?.performSegue(
//                withIdentifier: SegueId.create.rawValue,
//                sender: nil
//            )
//        }
//        controller.onPrepareForSegue = { [weak self] segue, _, _ in
//            if let createVC = segue.destination as? WorkoutTypeCreateViewController {
//                self?.configureCreateViewController(createVC)
//            }
//        }
    }
    
    private func configureCreateViewController(_ controller: WorkoutTypeCreateViewController) {
        
        controller.onFinish = { [weak self, weak controller] title in
            if let title = title, !title.isEmpty {
//
                controller?.showProgressHUD()
                let newWorkoutType = FirebaseData.WorkoutType(
                    title: title,
                    createdAt: Date(),
                    createdBy: Auth.auth().currentUser?.uid ?? ""
                )
                Firestore.firestore().upload(object: newWorkoutType) { result in
                    controller?.hideProgressHUD()
                    
                    switch result {
                    case let .success(createdType):
                        self?.onFinish?(WorkoutType(firebaseData: createdType.1, remoteId: createdType.0))
                    case .failure:
                        break
// TODO: -
                    }
                }
//                FirebaseManager.sharedInstance.makeWorkoutType(
//                    withTitle: title
//                ) { type in
//
//                    controller?.hideProgressHUD()
//                    self?.onFinish?(type)
//                }
            }
        }
    }
}
