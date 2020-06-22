import UIKit
import Firebase

// Так чего хочется
// Чтобы можно было описать список как
// 1. тип сущности + опционально qeury
// 2. Graph, по которому нужно зарезолвить все dependencies
// 3. Чтобы dataSource собирался из этого всего автоматически и наружу торчал только он.
// При любых изменениях всех отображаемых данных они должны автоматом долетать до клиента
// dataSource перегенерироваться и долетать до view controller
// Чтобы можно было отписаться и подписаться на все зависимости при уходе/приходе на экран

protocol ConfigurableCell {
    
    associatedtype T
    
    func configure(with object: T)
    static var identifier: String { get }
}

class FirebaseListViewController<T, C: ConfigurableCell>:
    UITableViewController
    where C: UITableViewCell
{
    
    // MARK: - Output
    var onObjectSelected: ((_ object: T) -> Void)?
    
    var dataSource: [T] = []
    var listeners: [ListenerRegistration] = []
    
    // MARK: - NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        onPrepareForSegue?(segue, sender)
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onObjectSelected?(dataSource[indexPath.row])
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
