import UIKit

final class SessionsViewController:
    CoreDataListViewController<Session, SessionCell>
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
}
