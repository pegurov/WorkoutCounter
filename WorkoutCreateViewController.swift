import UIKit
import CoreData

final class WorkoutCreateViewController: UIViewController {
    
    // MARK: - Output
    var onAddUsers: (() -> Void)?
    var onFinished: ((_ name: String?) -> Void)?
    
    @IBOutlet weak var textFieldTitle: UITextField!
    
    // MARK: - User actions
    @IBAction func addButtonTap(_ sender: UIButton) {
        onAddUsers?()
    }
    
    @IBAction func cancelTap(_ sender: UIBarButtonItem) {
        onFinished?(nil)
    }
    
    @IBAction func readyTap(_ sender: UIBarButtonItem) {
        if let text = textFieldTitle.text, !text.isEmpty {
            onFinished?(text)
        }
    }
    
    // TODO embed core data list controller with a special predicate (store only
    // selected users ids
    
    // MARK: - NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        onPrepareForSegue?(segue, sender)
    }
}
