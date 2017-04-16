import UIKit
import CoreData

enum DeleteMode {
    case coreData
    case none
}

final class UsersViewController:
    CoreDataListViewController<User, UserCell> {

    var deleteMode: DeleteMode = .coreData
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        updateSelection()
//    }
    
//    private func updateSelection() {
//        
//        tableView?.indexPathsForSelectedRows?.forEach {
//            tableView?.deselectRow(at: $0, animated: false)
//        }
//        selectedUserIds.flatMap { (id: NSManagedObjectID) -> IndexPath? in
//            if let user = try? fetchedResultsController.managedObjectContext.existingObject(with: id) as? User, let unwrapped = user {
//                
//                return fetchedResultsController.indexPath(forObject: unwrapped)
//            }
//            return nil
//        }.forEach {
//            tableView?.selectRow(at: $0, animated: false, scrollPosition: .none)
//        }
//    }
    
    // MARK: - TableView
    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath) -> Bool {
        
        return deleteMode == .coreData
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
