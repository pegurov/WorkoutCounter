import UIKit
import CoreData

final class WorkoutTypeCoordinator:
    StoryboardCoordinator<WorkoutTypesViewController> {

    // MARK: - Output -
    var onFinish: ((_ object: WorkoutType) -> Void)? {
        didSet { rootViewController.onObjectSelected = onFinish }
    }

    // MARK: - Input -
    var selectedTypeId = NSManagedObjectID() {
        didSet { rootViewController.selectedIds = [selectedTypeId] }
    }
    
    // MARK: - StoryboardCoordinator -
    override func configureRootViewController(
        _ controller: WorkoutTypesViewController) {
        
        controller.managedObjectContext = coreDataStack.managedObjectContext
        controller.sortDescriptor = NSSortDescriptor(
            key: "title",
            ascending: true
        )
        controller.deletingEnabled = false
        controller.onInsertNewObject = { [weak controller] in
            controller?.performSegue(
                withIdentifier: SegueId.create.rawValue,
                sender: nil
            )
        }
        controller.onPrepareForSegue = { [weak self] segue, _, _ in
            if let createVC = segue.destination as? WorkoutTypeCreateViewController {
                self?.configureCreateViewController(createVC)
            }
        }
    }
    
    private func configureCreateViewController(
        _ controller: WorkoutTypeCreateViewController) {
        
        controller.onFinish = { [weak self, weak controller] title in
            
            if let title = title, !title.isEmpty {
                
                controller?.showProgressHUD()
                FirebaseManager.sharedInstance.makeWorkoutType(
                    withTitle: title
                ) { type in
                    
                    controller?.hideProgressHUD()
                    self?.onFinish?(type)
                }
            }
        }
    }
}
