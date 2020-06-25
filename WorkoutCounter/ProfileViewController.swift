import UIKit
import Firebase

final class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addGoalButton: UIButton!
    @IBOutlet weak var emptyState: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Input
    var userId: String!
    var user: User?
    
    // MARK: - Output
    var onLogout: (() -> Void)?
    var onAddGoal: ((User) -> Void)?
    var onGoalSelected: ((User.Goal, User) -> ())?
    var goalsList: GoalsListViewController?
    
    @IBAction func logoutTap(_ sender: UIBarButtonItem) {
        onLogout?()
    }
    @IBAction func addGoalTap(_ sender: UIButton) {
        guard let user = user else { return }
        onAddGoal?(user)
    }
    
    deinit {
        killUserSubscription()
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
            destination.onObjectSelected = { [weak self] goal in
                guard let user = self?.user else { return }
                self?.onGoalSelected?(goal, user)
            }
            destination.onUpdateEmptyState = { [weak self] isEmpty in
                self?.containerView.isHidden = isEmpty
                self?.emptyState.isHidden = !isEmpty
            }
            goalsList = destination
        } else {
            onPrepareForSegue?(segue, sender)
        }
    }
    
    private var userSubscription: ListenerRegistration?
    private func createUserSubscription() {
        guard userSubscription == nil else { return }
        
        killUserSubscription()
        userSubscription = Firestore.firestore().getObject(id: userId) { [weak self] (result: Result<(String, FirebaseData.User), Error>) in
            switch result {
            case let .success(id, data):
                self?.user = User(firebaseData: data, remoteId: id)
                self?.nameTextField.text = data.name
            case .failure:
                break
// TODO: - Handle error
            }
        }
    }
    
    private func killUserSubscription() {
        userSubscription?.remove()
        userSubscription = nil
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let userRemoteId = user?.remoteId else { return }
        guard let user = user?.firebaseData else { return }
        
        
        let updatedUser = FirebaseData.User(
            name: textField.text,
            createdAt: user.createdAt,
            goals: user.goals
        )
        Firestore.firestore().upload(object: updatedUser, underId: userRemoteId) { _ in }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
