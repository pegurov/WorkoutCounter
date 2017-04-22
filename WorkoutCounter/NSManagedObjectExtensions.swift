import CoreData
import ObjectiveC

struct RelationshipStub {
    
    enum RelationshipStubMode {
        case toOne(String)
        case toMany([String])
    }
    
    let from: NSManagedObject
    let fromKey: String
    let mode: RelationshipStubMode
}

extension NSManagedObject {
    
    func patchKeysWith(
        remoteId: String,
        json: [String: Any]) -> [RelationshipStub] {
        
//        var relationshipStubs: [RelationshipStub] = []
        
        print("\(json)")
        for key in json.keys {
            
            if let _ = self.class(ofPropertyNamed: key) as? NSOrderedSet.Type {
                // to many relationship
//                relationshipStubs
            } else if let _ = self.class(ofPropertyNamed: key) as? NSManagedObject.Type {
                // to one relationship
                
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
        print("\(self)")
        return []
    }
    
    func patchRelationshipsWith(
        _ relationships: [String: [Any]]) {

        for key in relationships.keys {
            
            if let _ = self.class(ofPropertyNamed: key) as? NSOrderedSet.Type {
                // to many relationship
                
            } else if let _ = self.class(ofPropertyNamed: key) as? NSManagedObject.Type {
                // to one relationship
//                setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
            }
        }
    }
}
