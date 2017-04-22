import Foundation
import Firebase
import FirebaseStorage
import CoreData
import FirebaseAuthUI

final class FirebaseManager {
    
    private(set) static var sharedInstance: FirebaseManager!
    
    static func startWith(
        coreDataStack: CoreDataStack) {
        
        sharedInstance = FirebaseManager()
        sharedInstance.coreDataStack = coreDataStack
        sharedInstance.ref = FIRDatabase.database().reference()
    }
    
    private var coreDataStack: CoreDataStack!
    private var ref: FIRDatabaseReference!
    
    func loadAllWorkoutTypes() {
        
        _ = ref.child("WorkoutType").observeSingleEvent(
            of: FIRDataEventType.value, with: { snapshot in
            
                let allTypes = snapshot.value as? [AnyHashable : Any] ?? [:]
                
                print("all types\n\(allTypes)")
        })
        
    }
    
    func updateDatabase(
        entityType: String,
        withServerValues: [AnyHashable : Any]) {
        
        
    }
    
    func patch() {
        
        return
        
        fix()
        
        synchronizeKeysFor(
            entityName: "User",
            keys: ["name"]
        )
        synchronizeKeysFor(
            entityName: "WorkoutType",
            keys: ["title"]
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
        
        synchronizeRelationships(
            entityName: "User",
            relationships: ["sessions"]
        )
        synchronizeRelationships(
            entityName: "Session",
            relationships: ["sets", "user", "workout", "createdBy"]
        )
        synchronizeRelationships(
            entityName: "Set",
            relationships: ["session", "createdBy"]
        )
        synchronizeRelationships(
            entityName: "Workout",
            relationships: ["sessions", "users", "createdBy", "type"]
        )
        synchronizeRelationships(
            entityName: "WorkoutType",
            relationships: ["workouts"]
        )
    }
    
    func fix() {
        
        // again, patch all entities created by!
        
        coreDataStack.saveContext()
    }
    
    func synchronizeKeysFor(
        entityName: String,
        keys: [String]) {
        
        let objects: [NSManagedObject]? = coreDataStack?.fetchAll(
            entityName: entityName
        )
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
                    let transformedValue = object.transformedValue(forKey: key)
                    fbEntity.child(key).setValue(transformedValue)
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
        
        let objects: [NSManagedObject]? = coreDataStack?.fetchAll(
            entityName: entityName
        )
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
                
                    if (object.value(forKey: relationship) == nil) {
                        assert(false, "relationship should not be nil!")
                    }
                    else if let relationshipManagedObject = object.value(forKey: relationship) as? NSManagedObject,
                        let remoteId = relationshipManagedObject.value(forKey: "remoteId") as? String {
                        
                        fbEntity.child(relationship).setValue(remoteId)
                    } else {
                        
                        let set = object.mutableOrderedSetValue(forKey: relationship)
                        var relationshipIds: [String] = []
                        set.forEach {
                            if let relationshipObject = $0 as? NSManagedObject,
                                let remoteId = relationshipObject.value(forKey: "remoteId") as? String {
                                
                                relationshipIds.append(remoteId)
                            } else {
                                assert(false, "Relationship in set has no remoteId")
                            }
                        }
                        fbEntity.child(relationship).setValue(relationshipIds)
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
