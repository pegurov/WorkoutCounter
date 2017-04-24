import UIKit
import CoreData

final class SelectUsersCoordinator: StoryboardCoordinator<UsersViewController> {

    // MARK: - Output -
    var onUserIdsUpdated: ((_ userIds: [NSManagedObjectID]) -> Void)?
    
    // MARK: - Input -
    var selectedUserIds = [NSManagedObjectID]() {
        didSet { rootViewController.selectedIds = selectedUserIds }
    }
   
    // MARK: - Coordinator -
    override func configureRootViewController(
        _ controller: UsersViewController) {

        controller.managedObjectContext = coreDataStack.managedObjectContext
        controller.sortDescriptor = NSSortDescriptor(
            key: "name",
            ascending: true
        )
        controller.onPrepareForSegue = { [weak self] segue, sender, object in
            
            if segue.identifier == SegueId.create.rawValue {
                
                let navVC = segue.destination as! UINavigationController
                let createVC = navVC.viewControllers.first as! UserCreateViewController
                self?.configureCreateController(createVC)
            }
        }
        controller.onInsertNewObject = { [weak self, weak controller] in
            
            controller?.performSegue(
                withIdentifier: SegueId.create.rawValue,
                sender: self
            )
        }
        controller.onObjectSelected = { [weak self] user in
            
            if (self?.selectedUserIds.removeWhere{ $0 == user.objectID } == nil) {
                self?.selectedUserIds.append(user.objectID)
            }
            self?.onUserIdsUpdated?(self?.selectedUserIds ?? [])
        }
    }
    
    private func configureCreateController(_ controller: UserCreateViewController) {
        
        controller.onFinish = { [weak controller] userName in
            
            if let userName = userName {
                
                controller?.startActivityIndicator()
                FirebaseManager.sharedInstance.makeUser(withName: userName) { _ in
                    controller?.stopActivityIndicator()
                    controller?.presentingViewController?.dismiss(
                        animated: true,
                        completion: nil
                    )
                }
            }
        }
    }
}
