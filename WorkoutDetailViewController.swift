import UIKit

final class WorkoutDetailViewController: UIViewController {
    
    var workout: Workout! {
        didSet {
            if workout.activeSession == nil {
                workout.activeSession = workout.sessions?.firstObject as? Session
                coreDataStack.saveContext()
                FirebaseManager.sharedInstance.syncRelationships(of: workout) {
                }
                sessionsVC?.tableView.reloadData()
            }
            forwardActiveSession()
        }
    }
    var sessions: [Session] {
        return sessionsVC?.fetchedResultsController.fetchedObjects ?? []
    }
    var coreDataStack: CoreDataStack!
    weak var sessionsVC: SessionsViewController?
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.text = workout?.type?.title
        buttons.forEach {
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 1
        }
        loadData()
    }
    
    private func forwardActiveSession() {
        
        if let activeSessionId = workout.activeSession?.objectID {
            sessionsVC?.selectedIds = [activeSessionId]
            sessionsVC?.tableView.reloadData()
        }
    }
    
    private func loadData() {
        
        startActivityIndicator()
        let node = ObjectGraphNode(
            children: [
                ObjectGraphNode(mode: .leaf("sessions"), children: [
                    ObjectGraphNode(mode: .leaf("sets")),
                    ObjectGraphNode(mode: .leaf("createdBy")),
                    ObjectGraphNode(mode: .leaf("user"))
                ]),
                ObjectGraphNode(mode: .leaf("type"))
            ]
        )
        let request = ObjectsRequest(
            entityName: "Workout",
            mode: .ids([workout.remoteId!]),
            node: node
        )
        FirebaseManager.sharedInstance.loadRequest(request, completion: { [weak self] result in
            if let workout = result.first as? Workout {
                self?.workout = workout
            }
            self?.stopActivityIndicator()
        })
    }
    
    // User actions
    @IBAction func addSetToCurrentSessionTap(_ sender: UIButton) {
        guard let currentSession = workout.activeSession,
            currentSession.active else { return }

        let alertController = UIAlertController(
            title: "Повторений", message: nil, preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(
            title: "Сохранить", style: .default, handler: { [weak self] alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField
            if let text = textField.text, !text.isEmpty {
                self?.addSetToCurrentSessionFromString(text)
            }
        })
        
        let cancelAction = UIAlertAction(
            title: "Отмена", style: .cancel, handler: { action -> Void in
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Повторений"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func addSetToCurrentSessionFromString(_ string: String) {
        
        startActivityIndicator()
        FirebaseManager.sharedInstance.makeWorkoutSet(
            count: Int16(string) ?? 0,
            time: NSDate()
        ) { [weak self] set in
            guard let strongSelf = self else { return }
            
            strongSelf.workout.activeSession?.addToSets(set)
            strongSelf.coreDataStack.saveContext()
            FirebaseManager.sharedInstance.syncRelationships(of: strongSelf.workout.activeSession!) {
                FirebaseManager.sharedInstance.syncRelationships(of: set) {
                    
                    self?.sessionsVC?.tableView.reloadData()
                    self?.advanceToNextSession()
                    self?.stopActivityIndicator()
                }
            }
        }
    }
    
    @IBAction func skipCurrentSessionTap(_ sender: UIButton) {
        guard let _ = workout.activeSession else { return }
        advanceToNextSession()
    }
    
    @IBAction func endCurrentSessionTap(_ sender: UIButton) {
        guard let currentSession = workout.activeSession else { return }

        currentSession.active = false
        coreDataStack.saveContext()
        
        startActivityIndicator()
        FirebaseManager.sharedInstance.syncKeysOfManagedObject(of: currentSession) { [weak self] in
            self?.stopActivityIndicator()
            self?.advanceToNextSession()
        }
    }

    // Implementation
    
    private func advanceToNextSession() {
        guard let currentSession = workout.activeSession,
            let indexOfCurrent = sessions.index(where: { $0.remoteId == currentSession.remoteId }) else { return }

        let currentAndAfter = sessions.suffix(from: indexOfCurrent)
        let beforeCurrent = sessions.prefix(upTo: indexOfCurrent)
        let newOrder = currentAndAfter + beforeCurrent
        for session in newOrder.dropFirst() {
            if session.active {
                workout.activeSession = session
                if let activeSessionId = workout.activeSession?.objectID {
                    sessionsVC?.selectedIds = [activeSessionId]
                }
                coreDataStack.saveContext()
                startActivityIndicator()
                FirebaseManager.sharedInstance.syncRelationships(of: workout) { [weak self] in
                    self?.stopActivityIndicator()
                    self?.sessionsVC?.tableView.reloadData()
                }
                break
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {

        let session = sessions[indexPath.row]
        if session.active && session == workout.activeSession { return }
        
        let alertController = UIAlertController(
            title: "Действия", message: nil, preferredStyle: .alert
        )
        if !session.active {
            let action = UIAlertAction(
                title: "Активировать",
                style: .default,
                handler: { [weak self] alert -> Void in
                    
                    session.active = true
                    self?.coreDataStack.saveContext()
                    FirebaseManager.sharedInstance.syncKeysOfManagedObject(
                        of: session
                    ) {
                        self?.forwardActiveSession()
                    }
            })
            alertController.addAction(action)
        }
        if session != workout.activeSession {
            let action = UIAlertAction(
                title: "Сделать текущим",
                style: .default,
                handler: { [weak self] alert -> Void in
                    
                    session.active = true
                    self?.workout.activeSession = session
                    self?.coreDataStack.saveContext()
                    FirebaseManager.sharedInstance.syncKeysOfManagedObject(
                        of: session
                    ) {
                        if let workout = self?.workout {
                            FirebaseManager.sharedInstance.syncRelationships(
                                of: workout
                            ) {
                                self?.forwardActiveSession()
                            }
                        }
                    }
            })
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(
            title: "Отмена", style: .cancel, handler: { action -> Void in
        })
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?, _ object: Workout) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.embed.rawValue {
            
            let embedded = segue.destination as! SessionsViewController
            embedded.managedObjectContext = coreDataStack.managedObjectContext
            embedded.sortDescriptor = NSSortDescriptor(
                key: "remoteId",
                ascending: true
            )
            embedded.predicate = NSPredicate(
                format: "workout.remoteId == %@",
                workout.remoteId!
            )
            embedded.onSelectedRow = { [weak self] tableView, indexPath in
                self?.tableView(tableView, didSelectRowAt: indexPath)
            }
            if let activeSessionId = workout.activeSession?.objectID {
                embedded.selectedIds = [activeSessionId]
            }
            sessionsVC = embedded
        } else {
            onPrepareForSegue?(segue, sender, workout)
        }
    }
}
