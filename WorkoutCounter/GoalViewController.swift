import UIKit
import Firebase

final class GoalViewController: UIViewController {
    
    // MARK: - Input
    var user: User!
    var goal: Goal? { didSet { updateLabelWithGoal() } }
    var type: ActivityType? { didSet { updateWithActivityType(type: type) } }
    
    // MARK: - Output
    var onSelectTypeTap: (() -> ())?
    var onFinish: (() -> ())?
    
    // MARK: - IBOutlets + actions
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    
    @IBAction func onSelectTypeTap(_ sender: Any) {
        onSelectTypeTap?()
    }
    
    @IBAction func onAddTap(_ sender: Any) {
        guard let textCount = countTextField.text, let count = Int(textCount), count > 0 else {
            return
        }
        
        if let goal = goal {
            save(goal: goal, updatedCount: count)
        } else if let type = type {
            createGoal(type: type, count: count)
        }
    }
    
    @IBAction func onDeleteTap(_ sender: UIBarButtonItem) {
        guard let goal = goal else { return }
        delegeGoal(goal: goal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if goal != nil {
            updateLabelWithGoal()
        }
    }
    
    private func updateLabelWithGoal() {
        navigationItem.rightBarButtonItem?.isEnabled = (goal != nil)
        guard let goal = goal else { return }
        
        countTextField?.text = "\(goal.count)"
        typeLabel?.text = goal.type?.title
    }
    
    private func save(goal: Goal, updatedCount: Int) {
        showProgressHUD()
        
        let updatedGoals: [FirebaseData.User.Goal] = user.firebaseData.goals.map { oldGoal in
            if oldGoal.type == goal.firebaseData.type {
                return FirebaseData.User.Goal(
                    count: updatedCount,
                    type: oldGoal.type,
                    createdAt: oldGoal.createdAt
                )
            } else {
                return oldGoal
            }
        }
        let updatedUser = FirebaseData.User(
            name: user.name,
            createdAt: user.createdAt,
            goals: updatedGoals
        )
        Firestore.firestore().upload(object: updatedUser, underId: user.remoteId) { [weak self] result in
            self?.hideProgressHUD()
            switch result {
            case .success: self?.onFinish?()
            case .failure: break
// TODO: - Handle error
            }
        }
    }
    
    private func createGoal(type: ActivityType, count: Int) {
        showProgressHUD()

        var updatedGoals = user.firebaseData.goals
        updatedGoals.append(FirebaseData.User.Goal(
            count: count,
            type: type.remoteId,
            createdAt: Date())
        )
        let updatedUser = FirebaseData.User(
            name: user.name,
            createdAt: user.createdAt,
            goals: updatedGoals
        )
        Firestore.firestore().upload(object: updatedUser, underId: user.remoteId) { [weak self] result in
            self?.hideProgressHUD()
            switch result {
            case .success: self?.onFinish?()
            case .failure: break
// TODO: - Handle error
            }
        }
    }
    
    private func delegeGoal(goal: Goal) {
        showProgressHUD()
        
        let updatedGoals: [FirebaseData.User.Goal] = user.firebaseData.goals.compactMap { oldGoal in
            return (oldGoal.type == goal.firebaseData.type) ? nil : oldGoal
        }
        let updatedUser = FirebaseData.User(
            name: user.name,
            createdAt: user.createdAt,
            goals: updatedGoals
        )
        Firestore.firestore().upload(object: updatedUser, underId: user.remoteId) { [weak self] result in
            self?.hideProgressHUD()
            switch result {
            case .success: self?.onFinish?()
            case .failure: break
// TODO: - Handle error
            }
        }
    }
    
    private func updateWithActivityType(type: ActivityType?) {
        guard let type = type else { return }
        
        if let existingGoal = user.goals.first(where: { $0.firebaseData.type == type.remoteId }) {
            goal = Goal(
                firebaseData: existingGoal.firebaseData,
                type: type
            )
        } else {
            typeLabel?.text = type.title
            countTextField?.text = nil
        }
    }
}
