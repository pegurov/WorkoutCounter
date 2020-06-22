import UIKit

final class GoalViewController: UIViewController {
    
    // MARK: - Input
    var goal: Goal? { didSet { updateLabelWithGoal() } }
    var type: WorkoutType? { didSet { typeLabel?.text = nil } }
    
    // MARK: - Output
    var onCreate: ((WorkoutType, Int) -> ())?
    var onSave: ((Goal, Int) -> ())?
    
    var onSelectTypeTap: (() -> ())?
    
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
