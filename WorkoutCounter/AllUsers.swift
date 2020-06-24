import UIKit
import Firebase

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
        listeners.append(Firestore.firestore().getObjects { [weak self] (result: Result<[(String, FirebaseData.User)], Error>) in
            switch result {
            case .success(let value):
                self?.dataSource = value.map { User(firebaseData: $0.1, createdBy: nil) }
            case .failure:
                // TODO: - Handle error
                break
            }
        })
    }
}
