import UIKit
import CoreData

final class UsersViewController:
    CoreDataListViewController<User, UserCell> {

    var deletingEnabled = true
    var selectedUserIds: [NSManagedObjectID] = [] {
        didSet { tableView?.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: "UserCell", bundle: .main),
            forCellReuseIdentifier: UserCell.identifier
        )
    }
    
    // MARK: - TableView
    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath) -> Bool {
        
        return deletingEnabled
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(
            tableView,
            cellForRowAt: indexPath) as! UserCell
        let user = fetchedResultsController.object(at: indexPath)
        if selectedUserIds.contains(where: { $0 == user.objectID }) {
            cell.contentView.backgroundColor = .yellow
        } else {
            cell.contentView.backgroundColor = .white
        }
        return cell
    }
}
