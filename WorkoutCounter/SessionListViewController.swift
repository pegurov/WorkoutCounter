import UIKit

final class SessionCell: UITableViewCell, ConfigurableCell {
    
    static var identifier = "SessionCell"
    
    typealias T = Workout.Session
    
    func configure(with object: Workout.Session) {
        textLabel?.text = object.activity?.title
        detailTextLabel?.text = object.setsDescription
    }
}

final class SessionListViewController: FirebaseListViewController<Workout.Session, SessionCell> {
    
    // MARK: - Output
    var onDeleteSession: ((Int) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelectionDuringEditing = true
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = tableView.allowsSelection ? .disclosureIndicator : .none
        cell.selectionStyle = tableView.allowsSelection ? .default : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.allowsSelection
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            onDeleteSession?(indexPath.row)
        default:
            assertionFailure(); break
        }
    }
}
