import UIKit

final class WorkoutTypesViewController:
    CoreDataListViewController<WorkoutType, WorkoutTypeCell> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    private func loadData() {
        
        startActivityIndicator()
        let request = ObjectsRequest(
            entityName: "WorkoutType",
            mode: .all,
            node: ObjectGraphNode()
        )
        FirebaseManager.sharedInstance.loadRequest(request, completion: { [weak self] _ in
            self?.stopActivityIndicator()
        })
    }
}
