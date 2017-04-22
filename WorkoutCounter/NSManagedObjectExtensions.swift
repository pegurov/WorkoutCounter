import CoreData
import ObjectiveC

// Represents a node in the relationships tree
struct RelationshipNode {
    let children: [String: RelationshipNode]
}

extension RelationshipNode {
    
    init() {
        self.init(children: [:])
    }
}

// contains stubs pointing to one type of Entity
final class RelationshipStubsRequest {
    
    init(
        stubs: [RelationshipStub],
        entityName: String) {
        
        self.stubs = stubs
        self.entityName = entityName
    }
    
    let stubs: [RelationshipStub]
    let entityName: String
    
    var remoteIds: Set<String> {
        return Set(stubs.flatMap{ stub -> [String] in
            
            switch stub.mode {
            case .toOne(let id):
                return [id]
            case .toMany(let ids):
                return ids
            }
        })
    }
}

// A stub that represents a need to download additonal data
final class RelationshipStub {
    
    enum RelationshipStubMode {
        case toOne(String)
        case toMany([String])
    }
    
    init(
        from: NSManagedObject,
        fromKey: String,
        mode: RelationshipStubMode,
        node: RelationshipNode) {
        
        self.from = from
        self.fromKey = fromKey
        self.mode = mode
        self.node = node
    }
    
    let from: NSManagedObject
    let fromKey: String
    let mode: RelationshipStubMode
    let node: RelationshipNode
    
    var toEntityName: String? {
        let relationshipDescription = from.entity.relationshipsByName[fromKey]
        return relationshipDescription?.destinationEntity?.name
    }
}

extension NSManagedObject {
    
    @discardableResult
    func patchKeysWith(
        remoteId: String,
        json: [String: Any],
        resolving rootNode: RelationshipNode?) -> [RelationshipStub] {
        
        var relationshipStubs: [RelationshipStub] = []
        
        for key in json.keys {
// TODO: This can be refactored using just entity description
            if let _ = self.class(ofPropertyNamed: key) as? NSOrderedSet.Type,
                let toIds = json[key] as? [String: Any] {
        // to many relationship
                if let node = rootNode?.children[key] {
                    let newStub = RelationshipStub(
                        from: self,
                        fromKey: key,
                        mode: .toMany(Array(toIds.keys)),
                        node: node
                    )
                    relationshipStubs.append(newStub)
                }
            } else if let _ = self.class(ofPropertyNamed: key) as? NSManagedObject.Type,
                let toId = json[key] as? String {
        // to one relationship
                if let node = rootNode?.children[key] {
                    let newStub = RelationshipStub(
                        from: self,
                        fromKey: key,
                        mode: .toOne(toId),
                        node: node
                    )
                    relationshipStubs.append(newStub)
                }
            } else if let _ = self.class(ofPropertyNamed: key) as? NSDate.Type {
        // date
                if let double = json[key] as? Double {
                    setValue(Date(timeIntervalSince1970: double), forKey: key)
                } else {
                    assert(false, "Date which is not a double")
                }
            } else {
        // something else
                setValue(json[key], forKey: key)
            }
        }
        setValue(remoteId, forKey: "remoteId")
        return relationshipStubs
    }    
}
