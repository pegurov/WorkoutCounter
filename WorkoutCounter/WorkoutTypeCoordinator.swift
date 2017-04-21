import UIKit

final class WorkoutTypeCoordinator:
    StoryboardCoordinator<WorkoutTypesViewController> {

    // MARK: - Output -
    var onFinish: ((_ object: WorkoutType) -> Void)? {
        didSet { rootViewController.onObjectSelected = onFinish }
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
    }
}
