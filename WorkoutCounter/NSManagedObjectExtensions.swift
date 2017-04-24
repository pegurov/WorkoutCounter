import CoreData

// Represents a request for objects
final class ObjectsRequest {
    
    enum Mode {
        case all
        case ids([String])
    }
    
    let entityName: String
    let mode: Mode
    let node: ObjectGraphNode
    
    init(
        entityName: String,
        mode: Mode = .all,
        node: ObjectGraphNode = ObjectGraphNode()) {
        
        self.entityName = entityName
        self.mode = mode
        self.node = node
    }
}

// Represents a node in the objects graph
final class ObjectGraphNode {
    
    enum Mode {
        case root
        case leaf(String)
        
        static func ==( _ lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.root, .root):
                return true
            case (.leaf(let lhsKey), .leaf(let rhsKey)):
                return lhsKey == rhsKey
            default:
                return false
            }
        }
    }
    let mode: Mode
    let children: [ObjectGraphNode]
    
    init(mode: Mode = .root,
         children: [ObjectGraphNode] = []) {
        
        self.mode = mode
        self.children = children
    }
}

// A stub that represents a need to download additonal data
final class RelationshipStub {
    
    enum Mode {
        case toOne(String?)
        case toMany([String])
    }
    
    let toEntityName: String
    let fromKey: String
    let mode: Mode
    let node: ObjectGraphNode
    var entityStubs: [EntityStub] = []

    init(
        toEntityName: String,
        fromKey: String,
        mode: Mode,
        node: ObjectGraphNode) {
        
        self.toEntityName = toEntityName
        self.fromKey = fromKey
        self.mode = mode
        self.node = node
    }
}

// contains stubs pointing to one type of Entity
final class RelationshipStubsRequest {
    
    var stubs: [RelationshipStub] = []
    let entityName: String
    var remoteIds: Set<String> {
        return Set(stubs.flatMap{ stub -> [String] in
            
            switch stub.mode {
            case .toOne(let id):
                if let id = id {
                    return [id]
                } else {
                    return []
                }
            case .toMany(let ids):
                return ids
            }
        })
    }
    
    init(
        entityName: String) {
        
        self.entityName = entityName
    }
}

// A stub that represents entity
final class EntityStub {
    
    let entityName: String
    let remoteId: String
    let json: [String: Any]
    var relationshipStubs: [RelationshipStub] = []
    
    init(
        context: NSManagedObjectContext,
        entityName: String,
        remoteId: String,
        json: [String: Any],
        node: ObjectGraphNode) {
        
    // save properties
        self.entityName = entityName
        self.remoteId = remoteId
        self.json = json
        
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: entityName,
            in: context
        ) else {
            assert(false, "Unable to get entity description!")
            return
        }
        
    // fill relationship stubs
        var stubs: [RelationshipStub] = []
        node.children.forEach { childNode in
            
            if let relationship = entityDescription.relationshipsByName.first(where: { key, _ in
                childNode.mode == .leaf(key)
            }) {
                let mode: RelationshipStub.Mode
                if relationship.value.isToMany {
                    
                    if let keys = (json[relationship.key] as? [String: Any])?.keys {
                        mode = .toMany(Array(keys))
                    } else {
                        mode = .toMany([])
                    }
                } else {
                    mode = .toOne(json[relationship.key] as? String)
                }
                
                let newStub = RelationshipStub(
                    toEntityName: relationship.value.destinationEntity!.name!,
                    fromKey: relationship.key,
                    mode: mode,
                    node: childNode
                )
                stubs.append(newStub)
            }
        }
        relationshipStubs = stubs
    }
}
