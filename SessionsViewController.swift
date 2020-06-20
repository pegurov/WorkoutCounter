import UIKit

final class SessionsViewController:
    CoreDataListViewController<Session, SessionCell>
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
}
