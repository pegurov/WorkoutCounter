import UIKit

final class UserCreateViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    var onFinish: ((_ userName: String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Отмена",
            style: .done,
            target: self,
            action: #selector(cancel)
        )
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        onFinish?(nil)
    }

    @IBAction func addUserTap(_ sender: UIButton) {
        onFinish?(textField.text)
    }
}
