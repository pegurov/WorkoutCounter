import UIKit
import CoreData

final class UsersViewController: CoreDataListViewController<User, UserCell> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: "UserCell", bundle: .main),
            forCellReuseIdentifier: UserCell.identifier
        )
        loadData()
    }
    
    private func loadData() {
        
        startActivityIndicator()
        let node = ObjectGraphNode(
            children: [
                ObjectGraphNode(mode: .leaf("sessions"))
            ]
        )
        let request = ObjectsRequest(
            entityName: "User",
            mode: .all,
            node: node
        )
        FirebaseManager.sharedInstance.loadRequest(request, completion: { [weak self] _ in
            self?.stopActivityIndicator()
        })
    }
}
