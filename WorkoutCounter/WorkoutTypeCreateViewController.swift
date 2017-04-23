import UIKit

final class WorkoutTypeCreateViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    var onFinish: ((_ typeName: String?) -> Void)?
    
    @IBAction func addTap(_ sender: UIButton) {
        onFinish?(textField.text)
    }
}
