import UIKit
import Firebase

protocol ConfigurableCell {
    
    associatedtype T
    
    func configure(with object: T)
    static var identifier: String { get }
}

class FirebaseListViewController<T: Codable, C: ConfigurableCell>:
    UITableViewController
    where C: UITableViewCell
{
    var dataSource: [T] = []
    var query: ((CollectionReference) -> (Query))? = nil
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupForUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard listener == nil else { return }
        signupForUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignFromUpdates()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(
            withIdentifier: C.identifier,
            for: indexPath
        ) as! C
        let object = dataSource[indexPath.row]
        configureCell(cell, withObject: object)
        return cell
    }
    
    private func configureCell(_ cell: C, withObject: T) {
        cell.configure(with: withObject as! C.T)
    }
    
    // MARK: - Listening to updates
    private func signupForUpdates() {
        listener = Firestore.firestore().getObjects(query: query) { [weak self] (result: Result<[T], Error>) in
            switch result {
            case .success(let value):
                self?.dataSource = value
                self?.tableView.reloadData()
            case .failure:
                // TODO: - Handle error
                break
            }
        }
    }
    
    private func resignFromUpdates() {
        listener?.remove()
        listener = nil
    }
}

final class AllUsersViewController: FirebaseListViewController<User, UserCell> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: "UserCell", bundle: .main),
            forCellReuseIdentifier: UserCell.identifier
        )
    }
}
