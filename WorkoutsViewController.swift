import UIKit
import CoreData

final class WorkoutsViewController:
    CoreDataListViewController<Workout, WorkoutCell> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    private func loadData() {
        
        startActivityIndicator()
        let node = ObjectGraphNode(
            children: [
                ObjectGraphNode(mode: .leaf("type"))
            ]
        )
        let request = ObjectsRequest(
            entityName: "Workout",
            mode: .all,
            node: node
        )
        FirebaseManager.sharedInstance.loadRequest(request, completion: { [weak self] _ in
            self?.stopActivityIndicator()
        })
    }
}
