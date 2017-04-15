import UIKit
import CoreData

final class UsersCoordinator: Coordinator {

    var onFlowFinished: ((_ users: [User]) -> Void)?
    private var selectedUsers = [User]()
    
    private let storyboard: UIStoryboard = .users
    private var coreDataStack: CoreDataStack
    private var rootViewController: UIViewController?
    
    private enum SegueIds: String {
        case create
    }
    
    init(coreDataStack: CoreDataStack) {
        
        _ = UsersViewController()
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Coordinator -
    func start() -> UIViewController {
        
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let usersViewController = navigationController.viewControllers.first as! UsersViewController
        configureUsersController(usersViewController)
        rootViewController = navigationController
        return navigationController
    }
    
    // MARK: - Private implementation
    private func configureUsersController(_ controller: UsersViewController) {
        
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
            
            if segue.identifier == SegueIds.create.rawValue {
                
                let navVC = segue.destination as! UINavigationController
                let userCreateVC = navVC.viewControllers.first as! UserCreateViewController
                self?.configureCreateUserController(userCreateVC)
            }
        }
        controller.onInsertNewObject = { [weak self, weak controller] in
            
            controller?.performSegue(
                withIdentifier: SegueIds.create.rawValue,
                sender: self
            )
        }
        controller.onObjectSelected = { [weak self] user in
            self?.selectedUsers.append(user)
        }
        controller.onObjectDeselected = { [weak self] user in
            self?.selectedUsers.removeWhere { $0 == user }
        }
    }
    
    @objc private func usersViewControllerDoneAction(
        _ sender: UIBarButtonItem) {
        
        onFlowFinished?(selectedUsers)
    }
    
    private func configureCreateUserController(_ controller: UserCreateViewController) {
        
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
