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
        controller.onFinish = { [weak self, weak controller] in
            
            if let strongSelf = self,
                let type = strongSelf.selectedType,
                !strongSelf.selectedUsers.isEmpty {
                
                controller?.startActivityIndicator()
                FirebaseManager.sharedInstance.makeWorkout(
                    withType: type,
                    users: strongSelf.selectedUsers
                ) { workout in
                    
                    controller?.stopActivityIndicator()
                    self?.onFinish?(workout)
                }
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
            coreDataStack: coreDataStack,
            startInNavigation: false
        )
        selectUsersCoordinator?.selectedUserIds = existingUserIds
        selectUsersCoordinator?.onUserIdsUpdated = { [weak controller] userIds in
            
            controller?.usersViewController?.predicate = NSPredicate(
                format: "(self IN %@)", userIds
            )
        }
        navigationController?.pushViewController(
            selectUsersCoordinator!.rootViewController,
            animated: true
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
        if let selectedType = selectedType {
            selectTypeCoordinator?.selectedTypeId = selectedType.objectID
        }
        navigationController?.pushViewController(
            selectTypeCoordinator!.rootViewController,
            animated: true
        )
    }
}
