import CoreData

protocol CoreDataStack {
    
    var managedObjectContext: NSManagedObjectContext { get }
    func saveContext()
}
