import UIKit
import Firebase

protocol ConfigurableCell {
    
    associatedtype T
    
    func configure(with object: T)
    static var identifier: String { get }
}

class FirebaseListViewController<T, C: ConfigurableCell>:
    UITableViewController
    where C: UITableViewCell
{
    var dataSource: [T] = []
    var listeners: [ListenerRegistration] = []
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupForUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard listeners.isEmpty else { return }
        signupForUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignFromUpdates()
    }
    
    // MARK: - UITableViewController
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
    func signupForUpdates() {
        assertionFailure("override in subclasses")
    }
    
    private func resignFromUpdates() {
        listeners.forEach { $0.remove() }
        listeners = []
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
    
    override func signupForUpdates() {
        signupForUsersUpdates()
        
    }
    
    func signupForUsersUpdates() {
        listeners.append(Firestore.firestore().getObjects { [weak self] (result: Result<[FirebaseData.User], Error>) in
            switch result {
            case .success(let value):
                self?.dataSource = value.map { User(firebaseData: $0, createdBy: nil) }
                self?.tableView.reloadData()
            case .failure:
                // TODO: - Handle error
                break
            }
        })
    }
}
