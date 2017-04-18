import Foundation
import Firebase
import FirebaseStorage
import CoreData

final class FirebaseManager {
    
    static let sharedInstance = FirebaseManager()
    var coreDataStack: CoreDataStack?
    
    var ref: FIRDatabaseReference!
    
    func start() {
        
        ref = FIRDatabase.database().reference()
        
        synchronizeKeysFor(
            entityName: "User",
            keys: ["name"]
        )
        
        synchronizeKeysFor(
            entityName: "Workout",
            keys: ["date", "title"]
        )
        
        synchronizeKeysFor(
            entityName: "Session",
            keys: ["active"]
        )
        
        synchronizeKeysFor(
            entityName: "Set",
            keys: ["count", "time"]
        )
    }
    
    func synchronizeKeysFor(
        entityName: String,
        keys: [String]) {
        
        let objects: [NSManagedObject]? = coreDataStack?.fetchAll(entityName: entityName)
        objects?.forEach { object in
            
            if let remoteId = object.value(forKey: "remoteId") as? String? {
                
                let fbEntity: FIRDatabaseReference
                if let remoteId = remoteId {
                    fbEntity = ref.child(entityName).child(remoteId)
                } else {
                    fbEntity = ref.child(entityName).childByAutoId()
                    object.setValue(fbEntity.key, forKey: "remoteId")
                }
                // sync keys
                keys.forEach { key in
                    fbEntity.setValue([key: object.transformedValue(forKey: key)])
                }
            } else {
                assert(false, "Object has no remote id!")
            }
        }
        coreDataStack?.saveContext()
    }
    
    func synchronizeRelationships(
        entityName: String,
        relationships: [String]) {
        
        let objects: [NSManagedObject]? = coreDataStack?.fetchAll(entityName: entityName)
        objects?.forEach { object in
            
            if let remoteId = object.value(forKey: "remoteId") as? String? {
                
                let fbEntity: FIRDatabaseReference
                if let remoteId = remoteId {
                    fbEntity = ref.child(entityName).child(remoteId)
                } else {
                    assert(false, "Entity should have a remoteId by now")
                    fbEntity = ref.child(entityName).childByAutoId()
                }
                // sync relationships
                relationships.forEach { relationship in
                    
                    if let set = object.value(forKey: relationship) as? NSSet {
                        
                        var relationshipIds: [String] = []
                        set.forEach {
                            if let relationshipObject = $0 as? NSManagedObject,
                                let remoteId = relationshipObject.value(forKey: "remoteId") as? String {
                                
                                relationshipIds.append(remoteId)
                            } else {
                                assert(false, "Relationship in set has no remoteId")
                            }
                        }
                        fbEntity.setValue([relationship: relationshipIds])
                    } else if let relationshipObject = object.value(forKey: relationship) as? NSManagedObject,
                        let remoteId = relationshipObject.value(forKey: "remoteId") as? String {
                        
                        fbEntity.setValue([relationship: remoteId])
                    } else{
                        assert(false, "Relationship is not a set and has no remoteId")
                    }
                }
            } else {
                assert(false, "Object has no remote id!")
            }
        }
        coreDataStack?.saveContext()
    }
}

extension NSManagedObject {
    
    func transformedValue(forKey key: String) -> Any? {
        
        let realValue = value(forKey: key)
        if let date = realValue as? NSDate {
            return NSNumber(value: date.timeIntervalSince1970)
        }
        return realValue
    }
}
