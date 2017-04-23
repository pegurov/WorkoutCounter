import UIKit

extension Workout {
    
    func textRepresentation() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        var result = ""
        sessions?.forEach { session in
            
            let session = session as! Session
            result += formatter.string(from: date! as Date) + "\t"
            result += (type?.title ?? "") + "\t"
            result += (session.user!.name ?? "") + "\t\t\t\t"
            
            session.sets?.forEach { set in
                
                let set = set as! SessionSet
                result.append("\(set.count)\t")
            }
            result.append("\n")
        }
        return result
    }
}

class WorkoutResultViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextView!
    var workout: Workout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showResult()
    }
    
    func showResult() {
        textField.text = workout.textRepresentation()
    }
}
