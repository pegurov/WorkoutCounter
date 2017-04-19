import CoreData

protocol CoreDataStack {
    
    var managedObjectContext: NSManagedObjectContext { get }
    
    func saveContext()
    func fetchAll<T: NSFetchRequestResult>(entityName: String) -> [T]?
}
