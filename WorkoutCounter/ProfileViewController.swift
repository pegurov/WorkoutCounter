import UIKit
import Firebase

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addGoalButton: UIButton!
    
    // MARK: - Input
    var userId: String!
    
    // MARK: - Output
    var onLogout: (() -> Void)?
    var onAddGoal: (() -> Void)?
    var onGoalSelected: ((Goal) -> ())?
    
    @IBAction func logoutTap(_ sender: UIBarButtonItem) {
        onLogout?()
    }
    @IBAction func addGoalTap(_ sender: UIButton) {
        onAddGoal?()
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUserSubscription()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createUserSubscription()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        killUserSubscription()
    }
    
    // MARK: - NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == SegueId.embed.rawValue,
            let destination = segue.destination as? GoalsListViewController
        {
            destination.userId = userId
            destination.onObjectSelected = { [weak self] in
                self?.onGoalSelected?($0)
            }
        } else {
            onPrepareForSegue?(segue, sender)
        }
    }
    
    private var userSubscription: ListenerRegistration?
    private func createUserSubscription() {
        guard userSubscription == nil else { return }
        
        userSubscription = Firestore.firestore().getObject(id: userId) { [weak self] (result: Result<(String, FirebaseData.User), Error>) in
            switch result {
            case let .success(_, user):
                self?.nameLabel.text = user.name
            case .failure:
                self?.nameLabel.text = "Ошибка загрузки пользователя"
            }
        }
    }
    
    private func killUserSubscription() {
        userSubscription?.remove()
        userSubscription = nil
    }
}
