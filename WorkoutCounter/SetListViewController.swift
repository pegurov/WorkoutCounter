import UIKit
import Firebase

final class SetCell: UITableViewCell, ConfigurableCell {
    
    static var identifier = "SetCell"
    
    typealias T = Workout.Session.Set
    
    func configure(with object: Workout.Session.Set) {
        textLabel?.text = object.count.clean
    }
}

final class SetListViewController: FirebaseListViewController<Workout.Session.Set, SetCell> {
    
    // MARK: - Input
    var workout: Workout!
    var sessionIndex: Int!
    
    override func viewDidLoad() {
        makeDataSource()
        setupEditing()
    }

    // MARK: - Editing
    private func setupEditing() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(toggleEditingMode)
        )
    }
    
    @objc private func toggleEditingMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: tableView.isEditing ? .done : .edit,
            target: self,
            action: #selector(toggleEditingMode)
        )
    }
    
    // MARK: - Table view code
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activity = workout.sessions[sessionIndex].activity else { assertionFailure(); return }
        
        let existingSet = dataSource[indexPath.row]
        showEditSet(
            existingCount: existingSet.count,
            activityTitle: activity.title,
            maxCount: activity.maxCount,
            completion: { [weak self] newCount in
                self?.updateSet(index: indexPath.row, count: newCount)
            }
        )
    }
    
    // MARK: - Editing
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteSet(index: indexPath.row)
        default:
            assertionFailure(); break
        }
    }
    
    // MARK: - Making the data source
    private func makeDataSource() {
        guard
            let workout = workout,
            let index = sessionIndex,
            index < workout.sessions.count
        else { assertionFailure(); return }
        
        dataSource = workout.sessions[index].sets
    }
    
    // MARK: - Modifying data
    private func updateSet(index setIndex: Int, count: Double) {
        let updatedWorkout = FirebaseData.Workout(
            createdBy: workout.firebaseData.createdBy,
            createdAt: workout.firebaseData.createdAt,
            sessions: workout.firebaseData.sessions?.enumerated().map { indexOfSession, session in
                if indexOfSession == sessionIndex {
                    return .init(
                        activity: session.activity,
                        createdAt: session.createdAt,
                        sets: session.sets?.enumerated().map { indexOfSet, set in
                            if indexOfSet == setIndex {
                                return .init(count: count, createdAt: set.createdAt)
                            } else { return set }
                        }
                    )
                } else { return session }
            }
        )
        Firestore.firestore().upload(object: updatedWorkout, underId: workout.remoteId) { _ in
// TODO: - Handle error
        }
        
        self.workout = Workout(
            firebaseData: updatedWorkout,
            remoteId: workout.remoteId,
            createdBy: workout.createdBy,
            sessions: workout.sessions.enumerated().map { indexOfSession, session in
                if sessionIndex == indexOfSession {
                    return .init(
                        firebaseData: (updatedWorkout.sessions ?? [])[indexOfSession],
                        activity: session.activity,
                        goal: session.goal
                    )
                } else { return session }
            }
        )
        makeDataSource()
    }
    
    private func deleteSet(index setIndex: Int) {
        let updatedWorkout = FirebaseData.Workout(
            createdBy: workout.firebaseData.createdBy,
            createdAt: workout.firebaseData.createdAt,
            sessions: workout.firebaseData.sessions?.enumerated().map { indexOfSession, session in
                if indexOfSession == sessionIndex {
                    return .init(
                        activity: session.activity,
                        createdAt: session.createdAt,
                        sets: session.sets?.enumerated().compactMap { indexOfSet, set in
                            return indexOfSet == setIndex ? nil : set
                        }
                    )
                } else { return session }
            }
        )
        Firestore.firestore().upload(object: updatedWorkout, underId: workout.remoteId) { _ in
// TODO: - Handle error
        }
        
        self.workout = Workout(
            firebaseData: updatedWorkout,
            remoteId: workout.remoteId,
            createdBy: workout.createdBy,
            sessions: workout.sessions.enumerated().map { indexOfSession, session in
                if sessionIndex == indexOfSession {
                    return .init(
                        firebaseData: (updatedWorkout.sessions ?? [])[indexOfSession],
                        activity: session.activity,
                        goal: session.goal
                    )
                } else { return session }
            }
        )
        makeDataSource()
    }
}
