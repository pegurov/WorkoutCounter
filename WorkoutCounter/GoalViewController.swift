import UIKit
import Firebase

final class GoalViewController: UIViewController {
    
    // MARK: - Input
    var user: User!
    var goal: User.Goal? { didSet { updateLabelWithGoal() } }
    var activity: Activity? { didSet { updateWith(activity: activity) } }
    
    // MARK: - Output
    var onSelectActivityTap: (() -> ())?
    var onFinish: (() -> ())?
    
    // MARK: - IBOutlets + actions
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    
    @IBAction func onSelectActivityTap(_ sender: Any) {
        onSelectActivityTap?()
    }
    
    @IBAction func onSaveTap(_ sender: Any) {
        guard let activity = goal?.activity ?? activity else { return }
        guard let textCount = countTextField.text, let count = Double(textCount), count > 0, count < activity.maxCount else {
            return
        }
        
        if let goal = goal {
            save(goal: goal, updatedCount: count)
        } else if let activity = self.activity {
            createGoal(activity: activity, count: count)
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
        
        countTextField?.text = goal.count.clean
        activityLabel?.text = goal.activity?.title
    }
    
    private func save(goal: User.Goal, updatedCount: Double) {
        showProgressHUD()
        
        let updatedGoals: [FirebaseData.User.Goal] = (user.firebaseData.goals ?? []).map { oldGoal in
            if oldGoal.activity == goal.firebaseData.activity {
                return FirebaseData.User.Goal(
                    count: updatedCount,
                    activity: oldGoal.activity,
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
    
    private func createGoal(activity: Activity, count: Double) {
        showProgressHUD()

        var updatedGoals = (user.firebaseData.goals ?? [])
        updatedGoals.append(FirebaseData.User.Goal(
            count: count,
            activity: activity.remoteId,
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
    
    private func delegeGoal(goal: User.Goal) {
        showProgressHUD()
        
        let updatedGoals: [FirebaseData.User.Goal] = (user.firebaseData.goals ?? []).compactMap { oldGoal in
            return (oldGoal.activity == goal.firebaseData.activity) ? nil : oldGoal
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
    
    private func updateWith(activity: Activity?) {
        guard let activity = activity else { return }
        
        if let existingGoal = user.goals.first(where: { $0.firebaseData.activity == activity.remoteId }) {
            goal = User.Goal(
                firebaseData: existingGoal.firebaseData,
                activity: activity
            )
        } else {
            activityLabel?.text = activity.title
            countTextField?.text = nil
        }
    }
}
