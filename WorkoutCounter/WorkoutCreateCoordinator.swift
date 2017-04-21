import UIKit

class WorkoutCreateCoordinator:
    StoryboardCoordinator<WorkoutCreateViewController> {

    // MARK: - Output -
    var onFinish: ((_ createdWorkout: Workout?) -> Void)?
    
    // MARK: - Private proerpties -
    private var selectUsersCoordinator: SelectUsersCoordinator?
    private var selectTypeCoordinator: WorkoutTypeCoordinator?
    private var selectedUsers: [User] {
        
        let usersController = rootViewController.usersViewController
        return usersController?.fetchedResultsController.fetchedObjects ?? []
    }
    private var selectedType: WorkoutType?
    
    // MARK: - Coordinator -
    override func configureRootViewController(
        _ controller: WorkoutCreateViewController) {
        
        controller.coreDataStack = coreDataStack
        controller.onAddUsers = { [weak self, weak controller] in
            guard let controller = controller else { return }
            
            self?.showUsersAdd(from: controller)
        }
        controller.onSelectType = { [weak self, weak controller] in
            guard let controller = controller else { return }
            
            self?.showSelectType(from: controller)
        }
        controller.onFinish = { [weak self] in
            
            if let strongSelf = self,
                let type = strongSelf.selectedType,
                !strongSelf.selectedUsers.isEmpty {
                
                let context = strongSelf.coreDataStack.managedObjectContext
                let newWorkout = Workout(context: context)
                newWorkout.date = NSDate()
                newWorkout.type = type
                let sessions: [Session] = strongSelf.selectedUsers.map {
                    let newSession = Session(context: context)
                    newSession.user = $0
                    return newSession
                }
                newWorkout.sessions = NSOrderedSet(array: sessions)
                strongSelf.coreDataStack.saveContext()
                
                self?.onFinish?(newWorkout)
            }
        }
        controller.onCancel = { [weak self] in
            self?.onFinish?(nil)
        }
    }
    
    // MARK: - Starting users add flow
    private func showUsersAdd(from controller: WorkoutCreateViewController) {
        
        let existingUserIds = selectedUsers.map { $0.objectID } 
        selectUsersCoordinator = SelectUsersCoordinator(
            storyboard: .user,
            coreDataStack: coreDataStack
        )
        selectUsersCoordinator?.selectedUserIds = existingUserIds
        selectUsersCoordinator?.onFlowFinished = {
            [weak controller, weak rootViewController] userIds in
            
            rootViewController?.usersViewController?.predicate = NSPredicate(
                format: "(self IN %@)", userIds
            )
            controller?.dismiss(animated: true, completion: nil)
        }
        controller.present(
            selectUsersCoordinator!.navigationController!,
            animated: true,
            completion: nil
        )
    }
    
    // MARK: - Starting select type
    private func showSelectType(from controller: WorkoutCreateViewController) {
        
        selectTypeCoordinator = WorkoutTypeCoordinator(
            storyboard: .workoutType,
            coreDataStack: coreDataStack,
            startInNavigation: false
        )
        selectTypeCoordinator?.onFinish = {
            [weak self, weak controller] workoutType in
            guard let controller = controller else { return }
            
            self?.selectedType = workoutType
            controller.labelType.text = workoutType.title
            self?.navigationController?.popToViewController(
                controller,
                animated: true
            )
        }
        navigationController?.pushViewController(
            selectTypeCoordinator!.rootViewController,
            animated: true
        )
    }
}
