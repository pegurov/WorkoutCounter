import UIKit

final class GoalViewController: UIViewController {
    
    // MARK: - Input
    var goal: Goal? { didSet { updateLabelWithGoal() } }
    var type: ActivityType? {
        didSet {
            typeLabel?.text = type?.title
            countTextField.text = nil
        }
    }
    
    // MARK: - Output
    var onCreate: ((ActivityType, Int) -> ())?
    var onSave: ((Goal, Int) -> ())?
    var onSelectTypeTap: (() -> ())?
    var onDeleteTap: ((Goal) -> ())?
    
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
            onSave?(goal, count)
        } else if let type = type {
            onCreate?(type, count)
        }
    }
    
    @IBAction func onDeleteTap(_ sender: UIBarButtonItem) {
        guard let goal = goal else { return }
        onDeleteTap?(goal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if goal != nil {
            updateLabelWithGoal()
        }
    }
    
    private func updateLabelWithGoal() {
        guard let goal = goal else { return }
        
        countTextField?.text = "\(goal.count)"
        typeLabel?.text = goal.type?.title
    }
}
