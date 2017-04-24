import UIKit

final class SessionsViewController: CoreDataListViewController<Session, SessionCell> {

    var onSelectedRow: ((UITableView, IndexPath) -> Void)?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectedRow?(tableView, indexPath)
    }
}
