import UIKit

final class GoalCreateViewController: UIViewController {
    
    // MARK: - Input
    var type: WorkoutType? {
        didSet { typeLabel.text = type?.title }
    }
    
    // MARK: - Output
    var onAddTap: ((WorkoutType, Int) -> ())?
    var onSelectTypeTap: (() -> ())?
    
    // MARK: - IBOutlets + actions
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    
    @IBAction func onSelectTypeTap(_ sender: Any) {
        onSelectTypeTap?()
    }
    
    @IBAction func onAddTap(_ sender: Any) {
        guard
            let type = type,
            let textCount = countTextField.text,
            let count = Int(textCount)
        else { return }
        
        onAddTap?(type, count)
    }
}
