import UIKit
import CoreData

final class SelectUsersCoordinator: StoryboardCoordinator<UsersViewController> {

    // MARK: - Output -
    var onFlowFinished: ((_ userIds: [NSManagedObjectID]) -> Void)?
    
    // MARK: - Input -
    var selectedUserIds = [NSManagedObjectID]()
   
    // MARK: - Coordinator -
    override func configureRootViewController(
        _ controller: UsersViewController) {

        let readyItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(usersViewControllerDoneAction(_:))
        )
        controller.navigationItem.leftBarButtonItem = readyItem
            
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
        
        // Selection / deselection
        controller.selectedIds = selectedUserIds
        controller.onObjectSelected = { [weak self, weak controller] user in
            
            if (self?.selectedUserIds.removeWhere{ $0 == user.objectID } == nil) {
                self?.selectedUserIds.append(user.objectID)
            }
            controller?.selectedIds = self?.selectedUserIds ?? []
        }
    }
    
    @objc private func usersViewControllerDoneAction(
        _ sender: UIBarButtonItem) {
        
        onFlowFinished?(selectedUserIds)
    }
    
    private func configureCreateController(_ controller: UserCreateViewController) {
        
        controller.onFinish = { [weak self, weak controller] userName in
            
            if let strongSelf = self, let userName = userName {
                
                let context = strongSelf.coreDataStack.managedObjectContext
                let newUser = User(context: context)
                newUser.name = userName
                strongSelf.coreDataStack.saveContext()
            }
            
            controller?.presentingViewController?.dismiss(
                animated: true,
                completion: nil
            )
        }
    }
}
