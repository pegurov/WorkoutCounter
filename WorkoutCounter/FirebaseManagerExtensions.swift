import Foundation
import Firebase
import FirebaseStorage
import CoreData

extension FirebaseManager {
    
    @discardableResult
    func makeWorkoutType(withTitle title: String) -> WorkoutType {
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "WorkoutType",
            in: coreDataStack.managedObjectContext
        )
        let newObject = WorkoutType(
            entity: entityDescription!,
            insertInto: coreDataStack.managedObjectContext
        )
        newObject.title = title
        syncManagedObject(newObject)
        return newObject
    }
    
    @discardableResult
    func makeUser(withName name: String) -> User {
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "User",
            in: coreDataStack.managedObjectContext
        )
        let newObject = User(
            entity: entityDescription!,
            insertInto: coreDataStack.managedObjectContext
        )
        newObject.name = name
        syncManagedObject(newObject)
        return newObject
    }
    
    func syncManagedObject(
        _ object: NSManagedObject) {
        
        let description = object.entity
        let fbEntity: FIRDatabaseReference
        if let remoteId = object.value(forKey: "remoteId") as? String {
            fbEntity = ref.child(description.name!).child(remoteId)
        } else {
            fbEntity = ref.child(description.name!).childByAutoId()
            object.setValue(fbEntity.key, forKey: "remoteId")
        }

        // sync keys
        description.attributesByName.forEach { key, attribute in
            
            let value = object.value(forKey: key)
            if attribute.attributeType == .dateAttributeType {
                if let date = value as? NSDate {
                    fbEntity.child(key).setValue(date.timeIntervalSince1970)
                }
            } else if key != "remoteId" {
                fbEntity.child(key).setValue(value)
            }
        }
        // sync relationships
        description.relationshipsByName.forEach { key, relationship in
            
            let relationshipValue = object.value(forKey: key)
            if relationship.isToMany {
                
                let set = object.mutableOrderedSetValue(forKey: key)
                set.forEach {
                    
                    if let relationshipObject = $0 as? NSManagedObject,
                        let remoteId = relationshipObject.value(forKey: "remoteId") as? String {
                        
                        fbEntity.child(key).child(remoteId).setValue(true)
                    } else {
                        assert(false, "Relationship in set has no remoteId")
                    }
                }
            } else if let remoteId = relationshipValue as? String {
                fbEntity.child(key).setValue(remoteId)
            }
        }
    }
}
