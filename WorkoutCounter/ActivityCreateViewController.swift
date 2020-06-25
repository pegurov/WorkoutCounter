import UIKit

final class ActivityCreateViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    var onFinish: ((_ typeName: String?) -> Void)?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @IBAction func addTap(_ sender: UIButton) {
        onFinish?(textField.text)
    }
}
