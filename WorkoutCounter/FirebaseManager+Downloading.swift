import Foundation
import Firebase
import FirebaseStorage
import CoreData

ccbfkhcggcdfidgcivihigbudejrcgvuuhlilubgceth

    private(set) static var sharedInstance: FirebaseManager!
    
    static func startWith(
        coreDataStack: CoreDataStack) {
        
        sharedInstance = FirebaseManager()
        sharedInstance.coreDataStack = coreDataStack
        sharedInstance.ref = FIRDatabase.database().reference()
    }
    
    private(set) var coreDataStack: CoreDataStack!
    private(set) var ref: FIRDatabaseReference!
    
    func loadRequest(
        _ request: ObjectsRequest,
        completion: (([NSManagedObject]) -> Void)? = nil) {
        
        switch request.mode {
        case .all:
            loadAllObjects(
                request: request,
                completion: { [weak self] loadedObjects in
                    
                    let result = self?.processLoadedObjects(loadedObjects) ?? []
                    if let first = result.first {
                        let all: [NSManagedObject]? = self?.coreDataStack.fetchAll(
                            entityName: first.entity.name!
                        )
                        all?.forEach {
                            if !result.contains($0) {
                                self?.coreDataStack.managedObjectContext.delete($0)
                            }
                        }
                    }
                    self?.coreDataStack.saveContext()
                    completion?(result)
            })
        case .ids(let ids):
            loadObjectsByIds(
                ids,
                entityName: request.entityName,
                node: request.node,
                completion: { [weak self] loadedObjects in
                    
                    let result = self?.processLoadedObjects(loadedObjects)
                    self?.coreDataStack.saveContext()
                    completion?(result ?? [])
            })
        }
    }
    
    // MARK: - Loading objects -
    private func loadAllObjects(
        request: ObjectsRequest,
        completion: @escaping ([EntityStub]) -> Void) {
        
        ref.child(request.entityName).observeSingleEvent(
            of: FIRDataEventType.value,
            with: { [weak self] snapshot in
                
                let response = snapshot.value as? [String : Any] ?? [:]
                var entityStubs: [EntityStub] = []
                
                for remoteId in response.keys {
                    guard let json = response[remoteId] as? [String : Any],
                        let strongSelf = self else {
                            continue
                    }

                    let entityStub = EntityStub(
                        context: strongSelf.coreDataStack.managedObjectContext,
                        entityName: request.entityName,
                        remoteId: remoteId,
                        json: json,
                        node: request.node
                    )
                    entityStubs.append(entityStub)
                }
                self?.resolveEntityStubs(
                    entityStubs,
                    completion: {
                        completion(entityStubs)
                })
        })
    }
    
    private func resolveEntityStubs(
        _ entityStubs: [EntityStub],
        completion: @escaping () -> Void) {
        
        if entityStubs.isEmpty {
            completion()
        } else {
        
            let counter = Counter(number: entityStubs.count)
            entityStubs.forEach {
                self.resolveEntityStub($0, completion: {
                    counter.decrement()
                    if counter.isReady {
                        completion()
                    }
                })
            }
        }
    }
    
    private func resolveEntityStub(
        _ entityStub: EntityStub,
        completion: @escaping () -> Void) {
        
        resolveRelationshipStubs(
            entityStub.relationshipStubs,
            completion: completion
        )
    }
    
    private func resolveRelationshipStubs(
        _ relationships: [RelationshipStub],
        completion: @escaping () -> Void) {
        
        if relationships.isEmpty {
            completion()
        } else {
            
            let counter = Counter(number: relationships.count)
            relationships.forEach {
                self.resolveRelationshipStub($0, completion: {
                    counter.decrement()
                    if counter.isReady {
                        completion()
                    }
                })
            }
        }
    }
    
    private func resolveRelationshipStub(
        _ relationship: RelationshipStub,
        completion: @escaping () -> Void) {
        
        switch relationship.mode {
        case let .toOne(id):
            if let id = id {
                
                loadObjectById(
                    id,
                    entityName: relationship.toEntityName,
                    node: relationship.node,
                    completion: { loadedObject in
                 
                        if let loadedObject = loadedObject {
                            relationship.entityStubs = [loadedObject]
                        } else {
                            relationship.entityStubs = []
                        }
                        completion()
                })
            } else {
                completion()
            }
        case let .toMany(ids):
            
            loadObjectsByIds(
                ids,
                entityName: relationship.toEntityName,
                node: relationship.node,
                completion: { loadedObjects in
             
                    relationship.entityStubs = loadedObjects
                    completion()
            })
        }
    }
    
    private func loadObjectsByIds(
        _ ids: [String],
        entityName: String,
        node: ObjectGraphNode,
        completion: @escaping ([EntityStub]) -> Void) {
        
        if ids.isEmpty {
            completion([])
        } else {
            
            var loaded: [EntityStub] = []
            let counter = Counter(number: ids.count)
            ids.forEach {
                self.loadObjectById(
                    $0,
                    entityName: entityName,
                    node: node,
                    completion: { loadedObject in
                    
                        if let loadedObject = loadedObject {
                            loaded.append(loadedObject)
                        }
                        counter.decrement()
                        if counter.isReady {
                            completion(loaded)
                        }
                })
            }
        }
    }
    
    private func loadObjectById(
        _ id: String,
        entityName: String,
        node: ObjectGraphNode,
        completion: @escaping (EntityStub?) -> Void) {
     
        ref.child(entityName).child(id).observeSingleEvent(
            of: FIRDataEventType.value,
            with: { [weak self] snapshot in
                
                guard let json = snapshot.value as? [String : Any],
                    let strongSelf = self else {
                        
                        completion(nil)
                        return
                }
                
                let entityStub = EntityStub(
                    context: strongSelf.coreDataStack.managedObjectContext,
                    entityName: entityName,
                    remoteId: id,
                    json: json,
                    node: node
                )
                self?.resolveEntityStub(
                    entityStub,
                    completion: {
                
                        completion(entityStub)
                })
        })
    }
    
    // MARK: - Processing loaded objects
    @discardableResult
    private func processLoadedObjects(
        _ objects: [EntityStub]) -> [NSManagedObject] {
        
        let requests = relationshipRequestsFrom(objects: objects)
        let existingObjects = fetch(
            objects: objects,
            requests: requests
        )
        return objects.map {
            self.processLoadedObject(
                $0,
                existingObjects: existingObjects
            )
        }
    }
    
    private func relationshipRequestsFrom(
        objects: [EntityStub]) -> [RelationshipStubsRequest] {
        
        var requests = [String: RelationshipStubsRequest]()
        objects.forEach { object in
            object.relationshipStubs.forEach { relationshipStub in
                
                let request = requests[relationshipStub.toEntityName] ??
                    RelationshipStubsRequest(entityName: relationshipStub.toEntityName)
                request.stubs.append(relationshipStub)
                requests[relationshipStub.toEntityName] = request
            }
        }
        return Array(requests.values)
    }
    
    private func fetch(
        objects: [EntityStub],
        requests: [RelationshipStubsRequest]) -> [String: NSManagedObject] {
     
        var result = [String: NSManagedObject]()
        
        if objects.count > 0 {
            
            let remoteIds = objects.map { $0.remoteId }
            let predicate = NSPredicate(format: "(remoteId IN %@)", remoteIds)
            let fetchResult: [NSManagedObject]? = coreDataStack.fetch(
                entityName: objects.first!.entityName,
                predicate: predicate
            )
            fetchResult?.forEach {
                if let remoteId = $0.value(forKey: "remoteId") as? String {
                    result[remoteId] = $0
                }
            }
        }
        
        requests.forEach { request in
            
            let remoteIds = Array(request.remoteIds)
            let predicate = NSPredicate(format: "(remoteId IN %@)", remoteIds)
            let fetchResult: [NSManagedObject]? = coreDataStack.fetch(
                entityName: request.entityName,
                predicate: predicate
            )
            fetchResult?.forEach {
                if let remoteId = $0.value(forKey: "remoteId") as? String {
                    result[remoteId] = $0
                }
            }
        }
        return result
    }
    
    func processLoadedObject(
        _ objectStub: EntityStub,
        existingObjects: [String: NSManagedObject]) -> NSManagedObject {
        
        var managedObject: NSManagedObject! = existingObjects[objectStub.remoteId]
        if managedObject == nil {
            let entityDescription = NSEntityDescription.entity(
                forEntityName: objectStub.entityName,
                in: coreDataStack.managedObjectContext
            )
            managedObject = NSManagedObject(
                entity: entityDescription!,
                insertInto: coreDataStack.managedObjectContext
            )
        }
        
        // 1. process relationships
        objectStub.relationshipStubs.forEach { relationshipStub in
            
            let objects = self.processLoadedObjects(relationshipStub.entityStubs)
            switch relationshipStub.mode {
            case .toOne:
                if let relationshipObject = objects.first {
                    managedObject?.setValue(
                        relationshipObject,
                        forKey: relationshipStub.fromKey
                    )
                }
            case .toMany:
                
                managedObject?.setValue(
                    NSOrderedSet(array: objects),
                    forKey: relationshipStub.fromKey
                )
            }
        }
        
        // 2. process keys
        managedObject.patchKeysWith(
            remoteId: objectStub.remoteId,
            json: objectStub.json
        )
        return managedObject
    }
}

extension NSManagedObject {
    
    func patchKeysWith(
        remoteId: String,
        json: [String: Any]) {
        
        for key in json.keys {
            
            if entity.relationshipsByName[key] != nil {
                // relationship, skip
            } else if entity.attributesByName[key]?.attributeType == .dateAttributeType {
                if let double = json[key] as? Double {
                    setValue(Date(timeIntervalSince1970: double), forKey: key)
                } else {
                    assert(false, "Date which is not a double")
                }
            } else {
                setValue(json[key], forKey: key)
            }
        }
        setValue(remoteId, forKey: "remoteId")
    }
}
