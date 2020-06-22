import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addGoalButton: UIButton!
    
    // MARK: - Input
    var userId: String!
    var userName: String?
    
    // MARK: - Output
    var onLogout: (() -> Void)?
    var onAddGoal: (() -> Void)?
    
    @IBAction func logoutTap(_ sender: UIBarButtonItem) {
        onLogout?()
    }
    @IBAction func addGoalTap(_ sender: UIButton) {
        onAddGoal?()
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = userName
    }
    
    // MARK: - NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == SegueId.embed.rawValue,
            let destination = segue.destination as? GoalsListViewController
        {
            destination.userId = userId
        } else {
            onPrepareForSegue?(segue, sender)
        }
    }
}
