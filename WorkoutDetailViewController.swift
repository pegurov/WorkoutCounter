import UIKit

final class WorkoutDetailViewController:
    UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var workout: Workout!
    var sessions: [Session] {
        return (workout.sessions!.array as? [Session]) ?? []
    }
    var currentSession: Session?
    var coreDataStack: CoreDataStack!
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.text = workout?.type?.title
        currentSession = sessions.first
        buttons.forEach {
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    // User actions
    @IBAction func addSetToCurrentSessionTap(_ sender: UIButton) {
        guard let currentSession = currentSession,
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
        
        let newSet = Set(context: coreDataStack.managedObjectContext)
        newSet.count = Int16(string) ?? 0
        newSet.time = NSDate()
        currentSession?.addToSets(newSet)
        coreDataStack.saveContext()
        tableView.reloadData()
        
        advanceToNextSession()
    }
    
    @IBAction func skipCurrentSessionTap(_ sender: UIButton) {
        guard let _ = currentSession else { return }
        advanceToNextSession()
    }
    
    @IBAction func endCurrentSessionTap(_ sender: UIButton) {
        guard let currentSession = currentSession else { return }
        
        currentSession.active = false
        advanceToNextSession()
    }

    // Implementation
    
    private func advanceToNextSession() {
        guard let currentSession = currentSession,
            let indexOfCurrent = sessions.index(of: currentSession) else { return }
        
        let currentAndAfter = sessions.suffix(from: indexOfCurrent)
        let beforeCurrent = sessions.prefix(upTo: indexOfCurrent)
        let newOrder = currentAndAfter + beforeCurrent
        for session in newOrder.dropFirst() {
            if session.active {
                self.currentSession = session
                break
            }
        }
        tableView.reloadData()
    }
    
    // Table view
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        
        return sessions.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SessionCell.identifier,
            for: indexPath
        ) as! SessionCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(
        _ cell: SessionCell,
        at indexPath: IndexPath) {
        
        let session = sessions[indexPath.row]
        cell.configure(with: session)
        if session == currentSession {
            cell.contentView.backgroundColor = .yellow
        } else {
            cell.contentView.backgroundColor = .white
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        
        let session = sessions[indexPath.row]
        if session.active && session == currentSession { return }
        
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
                    self?.tableView.reloadData()
            })
            alertController.addAction(action)
        }
        if session != currentSession {
            let action = UIAlertAction(
                title: "Сделать текущим",
                style: .default,
                handler: { [weak self] alert -> Void in
                    
                    session.active = true
                    self?.currentSession = session
                    self?.coreDataStack.saveContext()
                    self?.tableView.reloadData()
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
        onPrepareForSegue?(segue, sender, workout)
    }
}
