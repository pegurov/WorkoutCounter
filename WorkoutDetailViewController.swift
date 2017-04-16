import UIKit

final class SessionCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Session
    static let identifier: String = "SessionCell"
    
    func configure(with object: Session) {
        textLabel?.text = object.user!.name ?? "" +
                          "\(object.active ? "" : " - закончил")"
        detailTextLabel?.text = object.setsDescription
    }
}

private extension Session {
    
    var setsDescription: String {
        guard let sets = sets?.array as? [Set],
            !sets.isEmpty else { return "Пока нет подходов" }
        
        var description = ""
        var totalCount: Int16 = 0
        sets.enumerated().forEach { index, set in
            
            description += (index == 0 ? "" : "+") + "\(set.count)"
            totalCount += set.count
        }
        description += "=\(totalCount)"
        return description
    }
}

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
        
        labelTitle.text = workout?.title
        currentSession = sessions.first
        buttons.forEach {
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    // User actions
    @IBAction func addSetToCurrentSessionTap(_ sender: UIButton) {
        guard let _ = currentSession else { return }
        
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
        self.currentSession = nil
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
}
