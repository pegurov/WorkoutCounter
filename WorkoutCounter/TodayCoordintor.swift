import UIKit
import Firebase

final class TodayCoordinator: StoryboardCoordinator<WorkoutViewController> {

//    // MARK: - Output -
//    var onFinish: ((_ object: WorkoutType) -> Void)? {
//        didSet { rootViewController.onObjectSelected = onFinish }
//    }
    
    private let userId: String
    
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
        
//        controller.onPrepareForSegue = { [weak self] segue, _ in
//            if let createVC = segue.destination as? WorkoutTypeCreateViewController {
//                self?.configureCreateViewController(createVC)
//            }
//        }
    }
    
//    private func configureCreateViewController(_ controller: WorkoutTypeCreateViewController) {
//
//        controller.onFinish = { [weak self, weak controller] title in
//            if let title = title, !title.isEmpty {
//
//                controller?.showProgressHUD()
//                let newWorkoutType = FirebaseData.WorkoutType(
//                    title: title,
//                    createdAt: Date(),
//                    createdBy: Auth.auth().currentUser?.uid ?? ""
//                )
//                Firestore.firestore().upload(object: newWorkoutType) { result in
//                    controller?.hideProgressHUD()
//
//                    switch result {
//                    case let .success(createdType):
//                        self?.onFinish?(WorkoutType(firebaseData: createdType.1, remoteId: createdType.0))
//                    case .failure:
//                        break
//// TODO: -
//                    }
//                }
//            }
//        }
//    }
}

