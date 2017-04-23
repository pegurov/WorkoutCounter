import CoreData

protocol CoreDataStack {
    
    var managedObjectContext: NSManagedObjectContext { get }
    
    func saveContext()
    func fetch<T: NSFetchRequestResult>(entityName: String, predicate: NSPredicate?) -> [T]?
    func fetchAll<T: NSFetchRequestResult>(entityName: String) -> [T]?
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}
