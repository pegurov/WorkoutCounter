import UIKit
import CoreData

final class WorkoutCreateViewController: UIViewController {

    // MARK: - Output
    var onAddUsers: (() -> Void)?
    var onSelectType: (() -> Void)?
    var onFinish: (() -> Void)?
    var onCancel: (() -> Void)?
    
    var coreDataStack: CoreDataStack!
    private(set) weak var usersViewController: UsersViewController?
    @IBOutlet weak var labelType: UILabel!
    
    // MARK: - User actions
    @IBAction func addButtonTap(_ sender: UIButton) {
        onAddUsers?()
    }
    
    @IBAction func selectTypeTap(_ sender: UIButton) {
        onSelectType?()
    }
    
    @IBAction func cancelTap(_ sender: UIBarButtonItem) {
        onCancel?()
    }
    
    @IBAction func readyTap(_ sender: UIBarButtonItem) {
        onFinish?()
    }
    
    // MARK: - NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.embed.rawValue {
            
            let controller = segue.destination as! UsersViewController
            usersViewController = controller
            controller.managedObjectContext = coreDataStack.managedObjectContext
            controller.sortDescriptor = NSSortDescriptor(
                key: "name",
                ascending: false
            )
            controller.predicate = NSPredicate(format: "(self IN %@)", [])
            controller.deletingEnabled = false
        } else {
            onPrepareForSegue?(segue, sender)
        }
    }
}
