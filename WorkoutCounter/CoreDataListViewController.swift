import UIKit
import CoreData

class CoreDataListViewController<T, C: ConfigurableCell>:
    UITableViewController,
    NSFetchedResultsControllerDelegate
    where T: NSManagedObject, C: UITableViewCell {
    
    private enum SegueIds: String {
        case embedTable
    }
    
    var onObjectSelected: ((_ object: T) -> Void)?
    var selectedObject: T?
    var selectedIds: [NSManagedObjectID] = [] {
        didSet { tableView?.reloadData() }
    }
    var deletingEnabled = false
    
// CORE DATA STACK
    var managedObjectContext: NSManagedObjectContext!
    var sortDescriptor: NSSortDescriptor?
    var predicate: NSPredicate? {
        didSet {
            
            fetchedResultsController.fetchRequest.predicate = predicate
            try! fetchedResultsController.performFetch()
            tableView.reloadData()
        }
    }
    
    var _fetchedResultsController: NSFetchedResultsController<T>? = nil
    var fetchedResultsController: NSFetchedResultsController<T> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest().copy() as! NSFetchRequest<T>
        
        // Edit the sort key as appropriate.
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        fetchRequest.predicate = predicate
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }
    
// NAVIGATION
    var onPrepareForSegue: ((_ segue: UIStoryboardSegue, _ sender: Any?, _ object: T?) -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        onPrepareForSegue?(segue, sender, selectedObject)
    }

// UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    var onInsertNewObject: (() -> Void)?
    @objc func insertNewObject(_ sender: Any) {
        onInsertNewObject?()
    }

// Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: C.identifier,
            for: indexPath
        ) as! C
        let object = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withObject: object)
        if selectedIds.contains(where: { $0 == object.objectID }) {
            cell.contentView.backgroundColor = .yellow
        } else {
            cell.contentView.backgroundColor = .white
        }
        return cell
    }

    func configureCell(_ cell: C, withObject: T) {
        cell.configure(with: withObject as! C.T)
    }
    
    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath) -> Bool {
        
        return deletingEnabled
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        
        selectedObject = fetchedResultsController.object(at: indexPath)
        onObjectSelected?(selectedObject!)
        tableView.deselectRow(at: indexPath, animated: true)
    }

// MARK: - Fetched results controller

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                // the cell can be nil
                if let cell = tableView.cellForRow(at: indexPath!) as? C {
                    configureCell(cell, withObject: anObject as! T)
                }
            case .move:
                // the cell can be nil
                if let cell = tableView.cellForRow(at: indexPath!) as? C {
                    configureCell(cell, withObject: anObject as! T)
                }
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default:
                fatalError()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
