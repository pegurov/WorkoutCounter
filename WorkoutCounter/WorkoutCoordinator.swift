import UIKit

final class WorkoutCoordinator: StoryboardCoordinator<WorkoutsViewController> {
    
    // MARK: - Output
    var onLogout: (() -> Void)?
    
    // MARK: - Private properties
    private var createCoordinator: WorkoutCreateCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    
    // MARK: - StoryboardCoordinator
    override func configureRootViewController(
        _ controller: WorkoutsViewController) {
        
        controller.managedObjectContext = coreDataStack.managedObjectContext
        controller.sortDescriptor = NSSortDescriptor(
            key: "date",
            ascending: false
        )
        controller.onPrepareForSegue = { [weak self] segue, sender, object in
            
            if segue.identifier == SegueId.detail.rawValue {
                
                let detailVC = segue.destination as! WorkoutDetailViewController
                self?.configureDetailController(detailVC, object: object!)
            }
        }
        controller.onInsertNewObject = { [weak self, weak controller] in
            guard let controller = controller else { return }
            
            self?.showCreate(from: controller)
        }
        controller.onObjectSelected = { [weak controller] workout in
            
            controller?.performSegue(
                withIdentifier: SegueId.detail.rawValue,
                sender: nil
            )
        }
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Профиль",
            style: .plain,
            target: self,
            action: #selector(profileTap)
        )
    }
    
    @objc
    private func profileTap() {
        
        profileCoordinator = ProfileCoordinator(
            storyboard: .profile,
            coreDataStack: coreDataStack,
            startInNavigation: false
        )
        profileCoordinator!.onLogout = onLogout
        navigationController?.pushViewController(
            profileCoordinator!.rootViewController,
            animated: true
        )
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
    
    // MARK: - Starting workout create flow
    private func showCreate(from controller: WorkoutsViewController) {
        
        createCoordinator = WorkoutCreateCoordinator(
            storyboard: .workoutCreate,
            coreDataStack: coreDataStack
        )
        createCoordinator?.onFinish = { [weak controller] workout in
            
            controller?.dismiss(animated: true, completion: { 
                
                if let workout = workout {
                    
                    controller?.selectedObject = workout
                    controller?.performSegue(
                        withIdentifier: SegueId.detail.rawValue,
                        sender: nil
                    )
                }
            })
        }
        if let navigation = createCoordinator?.navigationController {
            controller.present(navigation, animated: true, completion: nil)
        }
    }
}
