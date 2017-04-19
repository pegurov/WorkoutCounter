import UIKit

final class WorkoutCoordinator: Coordinator {
    
    private let storyboard: UIStoryboard = .workout
    private var coreDataStack: CoreDataStack
    private var rootViewController: UIViewController!
    
    private weak var listController: WorkoutsViewController?
    private weak var createController: WorkoutCreateViewController?
    private weak var usersInCreateController: UsersViewController?
    
    private var selectUsersCoordinator: UserCoordinator?
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Coordinator -
    func start() -> UIViewController {
        
        let navigationController =
            storyboard.instantiateInitialViewController() as! UINavigationController
        let controller =
            navigationController.viewControllers.first as! WorkoutsViewController
        configureWorkoutsController(controller)
        rootViewController = navigationController
        return navigationController
    }
    
    private func configureWorkoutsController(
        _ controller: WorkoutsViewController) {
        
        controller.managedObjectContext = coreDataStack.managedObjectContext
        controller.sortDescriptor = NSSortDescriptor(
            key: "date",
            ascending: false
        )
        controller.onPrepareForSegue = { [weak self] segue, sender, object in
            
            if segue.identifier == SegueId.create.rawValue {
                
                let navVC = segue.destination as! UINavigationController
                let createVC =
                    navVC.viewControllers.first as! WorkoutCreateViewController
                self?.configureCreateController(createVC)
            } else if segue.identifier == SegueId.detail.rawValue {
                
                let detailVC = segue.destination as! WorkoutDetailViewController
                self?.configureDetailController(detailVC, object: object!)
            }
        }
        controller.onInsertNewObject = { [weak self, weak controller] in
            
            controller?.performSegue(
                withIdentifier: SegueId.create.rawValue,
                sender: self
            )
        }
        controller.onObjectSelected = { [weak self] workout in
            
            controller.performSegue(
                withIdentifier: SegueId.detail.rawValue,
                sender: nil
            )
        }
        listController = controller
    }
    
    private func configureCreateController(
        _ controller: WorkoutCreateViewController) {
        
        controller.onPrepareForSegue = { [weak self] segue, sender in
            
            if segue.identifier == SegueId.embed.rawValue {
                
                let usersVC = segue.destination as! UsersViewController
                self?.configureUsersController(usersVC)
            }
        }
        controller.onAddUsers = { [weak self, weak controller] in
            
            if let controller = controller {
                self?.showUsersAdd(from: controller)
            }
        }
        controller.onFinished = { [weak self] workoutTitle in
            
            let users = self?.usersInCreateController?.fetchedResultsController.fetchedObjects
            if let strongSelf = self,
                let workoutTitle = workoutTitle,
                let users = users,
                !users.isEmpty {
                
                let context = strongSelf.coreDataStack.managedObjectContext
                let newWorkout = Workout(context: context)
                newWorkout.date = NSDate()
                newWorkout.title = workoutTitle
                let sessions: [Session] = users.map {
                    let newSession = Session(context: context)
                    newSession.user = $0
                    return newSession
                }
                newWorkout.sessions = NSOrderedSet(array: sessions)
                strongSelf.coreDataStack.saveContext()
                
                controller.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
                    
                    self?.listController?.selectedObject = newWorkout
                    self?.listController?.performSegue(
                        withIdentifier: SegueId.detail.rawValue,
                        sender: nil
                    )
                })
            } else if workoutTitle == nil {
                
                controller.presentingViewController?.dismiss(
                    animated: true,
                    completion: nil
                )
            }
        }
        createController = controller
    }
    
    private func configureUsersController(_ controller: UsersViewController) {
        
        controller.managedObjectContext = coreDataStack.managedObjectContext
        controller.sortDescriptor = NSSortDescriptor(
            key: "name",
            ascending: false
        )
        controller.predicate = NSPredicate(format: "(self IN %@)", [])
        controller.deleteMode = .none
        usersInCreateController = controller
    }
    
    private func configureDetailController(
        _ controller: WorkoutDetailViewController,
        object: Workout) {
        
        controller.workout = object
        controller.coreDataStack = coreDataStack
        controller.onPrepareForSegue = { segue, sender, object in
            
            if segue.identifier == SegueId.result.rawValue {
                
                let destination = segue.destination as! WorkoutResultViewController
                destination.workout = object
            }
        }
    }
    
    // MARK: - Starting users add scenario
    private func showUsersAdd(from controller: WorkoutCreateViewController) {
        
        let existingUserIds = usersInCreateController?.fetchedResultsController.fetchedObjects?.map { $0.objectID } ?? []
        selectUsersCoordinator = UserCoordinator(
            coreDataStack: coreDataStack,
            selectedUserIds: existingUserIds
        )
        selectUsersCoordinator?.onFlowFinished = { [weak controller, weak usersInCreateController] userIds in
            
            usersInCreateController?.predicate =
                NSPredicate(format: "(self IN %@)", userIds)
            controller?.dismiss(animated: true, completion: nil)
        }
        controller.present(
            selectUsersCoordinator!.start(),
            animated: true,
            completion: nil
        )
    }
}
