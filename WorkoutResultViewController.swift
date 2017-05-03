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
            
            (session.sets?.array as? [WorkoutSet])?.sorted {
                if let lTime = $0.time?.timeIntervalSince1970,
                    let rTime = $1.time?.timeIntervalSince1970 {
                    
                    return lTime < rTime
                }
                return true
            }.forEach {
                result.append("\($0.count)\t")
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
