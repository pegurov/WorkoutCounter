import Foundation
import Firebase
import FirebaseStorage
import CoreData

extension FirebaseManager {
    
    func makeWorkoutType(
        withTitle title: String,
        completion: @escaping ((WorkoutType) -> Void)) {
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "WorkoutType",
            in: coreDataStack.managedObjectContext
        )
        let newObject = WorkoutType(
            entity: entityDescription!,
            insertInto: coreDataStack.managedObjectContext
        )
        newObject.title = title
// TODO: Created by
        coreDataStack.saveContext()
        
        syncKeysOfManagedObject(of: newObject) { _ in
            self.syncRelationships(of: newObject) {
                completion(newObject)
            }
        }
    }
    
    func makeUser(
        firebaseId: String,
        firebaseName: String?,
        completion: @escaping ((User?) -> Void)) {
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "User",
            in: coreDataStack.managedObjectContext
        )
        let newObject = User(
            entity: entityDescription!,
            insertInto: coreDataStack.managedObjectContext
        )
        newObject.remoteId = firebaseId
        newObject.name = firebaseName ?? firebaseId
        
        syncKeysOfManagedObject(of: newObject) { [weak self] success in
            if success {
                self?.coreDataStack.saveContext()
                completion(newObject)
            } else {
                completion(nil)
            }
        }
    }
    
    func makeWorkout(
        withType type: WorkoutType,
        users: [User],
        completion: @escaping ((Workout) -> Void)) {
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "Workout",
            in: coreDataStack.managedObjectContext
        )
        let newObject = Workout(
            entity: entityDescription!,
            insertInto: coreDataStack.managedObjectContext
        )
        newObject.type = type
        newObject.date = Date()
// TODO: Created by
        
        let sessions: [Session] = users.map {
            let newSession = Session(context: coreDataStack.managedObjectContext)
            newSession.user = $0
            return newSession
        }
        newObject.sessions = NSOrderedSet(array: sessions)
        newObject.activeSession = sessions.first
        coreDataStack.saveContext()
        
        syncKeysOfManagedObject(of: newObject) { _ in
            self.syncRelationships(of: type) {
                
                let counter = Counter()
                sessions.forEach {
                    counter.increment()
                    self.syncKeysOfManagedObject(of: $0) { _ in
                        counter.decrement()
                        if counter.isReady {
                            self.syncRelationships(of: newObject) {
                               
                                let sessionsCounter = Counter()
                                sessions.forEach { session in
                                    sessionsCounter.increment()
                                    self.syncRelationships(of: session.user!) {
                                        self.syncRelationships(of: session) {
                                            sessionsCounter.decrement()
                                            if sessionsCounter.isReady {
                                                
                                                completion(newObject)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeWorkoutSet(
        count: Int16,
        time: Date,
        completion: @escaping ((WorkoutSet) -> Void)) {
        
        let entityDescription = NSEntityDescription.entity(
            forEntityName: "WorkoutSet",
            in: coreDataStack.managedObjectContext
        )
        let newObject = WorkoutSet(
            entity: entityDescription!,
            insertInto: coreDataStack.managedObjectContext
        )
        newObject.count = count
        newObject.time = time
        // TODO: Created by
        coreDataStack.saveContext()
        
        syncKeysOfManagedObject(of: newObject) { _ in
            completion(newObject)
        }
    }
    
    func addUserIds(ids: [NSManagedObjectID], to: Workout, completion: @escaping ((Workout) -> Void)) {
        
        assertionFailure()
        
//        // TODO:
//        let newUsers: [User] = ids.flatMap {
//            return coreDataStack.managedObjectContext.object(with: $0) as? User
//        }
//        let newSessions: [Session] = users.map {
//            let newSession = Session(context: coreDataStack.managedObjectContext)
//            newSession.user = $0
//            return newSession
//        }
//        newObject.sessions = NSOrderedSet(array: sessions)
//        newObject.activeSession = sessions.first
//        coreDataStack.saveContext()
    }
    
    func syncKeysOfManagedObject(
        of object: NSManagedObject,
        completion: @escaping ((Bool) -> Void))
    {
        let description = object.entity
        var data: [String: Any] = [:]
        description.attributesByName.forEach { key, attribute in

            let value = object.value(forKey: key)
            if key != "remoteId" {
                data[key] = value
            }
        }
        
        if let remoteId = object.value(forKey: "remoteId") as? String {
            let firebaseDocument = Firestore.firestore().collection(description.name!).document(remoteId)
            firebaseDocument.setData(data, merge: true) { error in
                completion(error != nil)
            }
        } else {
            var documentId: String?
            let newDocument = Firestore.firestore().collection(description.name!).addDocument(data: data) { [weak self] error in
                if error != nil {
                    object.setValue(documentId, forKey: "remoteId")
                    self?.coreDataStack.saveContext()
                }
                completion(error != nil)
            }
            documentId = newDocument.documentID
        }
    }
    
    func syncRelationships(
        of object: NSManagedObject,
        completion: @escaping (() -> Void)) {
        
        
        assertionFailure()
        
//        let counter = Counter()
//
//        let description = object.entity
//        let fbEntity: DatabaseReference
//        if let remoteId = object.value(forKey: "remoteId") as? String {
//            fbEntity = ref.child(description.name!).child(remoteId)
//        } else {
//            fbEntity = ref.child(description.name!).childByAutoId()
//            object.setValue(fbEntity.key, forKey: "remoteId")
//        }
//
//        // sync relationships
//        description.relationshipsByName.forEach { key, relationship in
//
//            let relationshipValue = object.value(forKey: key)
//            if relationship.isToMany {
//
//                let set = object.mutableOrderedSetValue(forKey: key)
//                set.forEach {
//
//                    if let relationshipObject = $0 as? NSManagedObject,
//                        let remoteId = relationshipObject.value(forKey: "remoteId") as? String {
//                        counter.increment()
//                        fbEntity.child(key).child(remoteId).setValue(true, withCompletionBlock: { _, _ in
//                            counter.decrement()
//                            if counter.isReady {
//                                completion()
//                            }
//                        })
//                    } else {
//                        assert(false, "Relationship in set has no remoteId")
//                    }
//                }
//            } else if let remoteId = (relationshipValue as? NSManagedObject)?.value(forKey: "remoteId") as? String {
//                counter.increment()
//                fbEntity.child(key).setValue(remoteId, withCompletionBlock: { _, _ in
//                    counter.decrement()
//                    if counter.isReady {
//                        completion()
//                    }
//                })
//            }
//        }
//        if counter.isReady {
//            completion()
//        }
    }
}

class Counter {
    
    private(set) var number: Int
    var isReady: Bool {
        return number == 0
    }
    
    init(number: Int = 0) {
        self.number = number
    }
    
    func increment() {
        number += 1
    }
    
    func decrement() {
        number -= 1
    }
}
