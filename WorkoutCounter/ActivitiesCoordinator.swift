import UIKit
import Firebase

final class ActivitiesCoordinator: StoryboardCoordinator<ActivityListViewController> {

    // MARK: - Output -
    var onFinish: ((_ object: Activity) -> Void)? {
        didSet { rootViewController.onObjectSelected = { [weak self] activity, _ in self?.onFinish?(activity) } }
    }

    // MARK: - StoryboardCoordinator -
    override func configureRootViewController(_ controller: ActivityListViewController) {
        controller.onAddTap = { [weak controller] in
            if Auth.auth().currentUser?.uid == "WG2gAa0V9lTxkjPYtqkJ6it0K1D2" {
                controller?.performSegue(withIdentifier: SegueId.add.rawValue, sender: nil)
            } else {
                let alert = UIAlertController(
                    title: "Добавление активности",
                    message: "Для добавления активности напишите на почту\npashaisthebest@gmail.com\nлибо в Telegram @pegurov",
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "Telegram", style: .default, handler: { action in
                    UIApplication.shared.open(URL(string: "https://t.me/pegurov")!, options: [:], completionHandler: nil)
                }))
                alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
                controller?.present(alert, animated: true, completion: nil)
            }
        }
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
                let newActivity = FirebaseData.Activity(
                    title: title,
                    maxCount: Double.greatestFiniteMagnitude,
                    createdAt: Date(),
                    createdBy: Auth.auth().currentUser?.uid ?? ""
                )
                Firestore.firestore().upload(object: newActivity) { result in
                    controller?.hideProgressHUD()
                    
                    switch result {
                    case let .success(data):
                        self?.onFinish?(Activity(firebaseData: data.1, remoteId: data.0))
                    case .failure:
                        break
// TODO: -
                    }
                }
            }
        }
    }
}
