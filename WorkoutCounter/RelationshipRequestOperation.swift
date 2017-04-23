// REMOVED FROM TARGET

/*
final class RelationshipRequestOperation: AsynchronousOperation {

    let request: RelationshipStubsRequest
    let completion: (([String: Any]) -> Void)
    
    init(
        request: RelationshipStubsRequest,
        completion: @escaping (([String: Any]) -> Void)) {
        
        self.request = request
        self.completion = completion
    }
    
    override func execute() {
    
        var counter: NSNumber = NSNumber(integerLiteral: 0)
        var result: [String: Any] = [:]
        
        let ref = FIRDatabase.database().reference()
        request.remoteIds.forEach { remoteId in
            counter = NSNumber(integerLiteral: counter.intValue + 1)
            
            ref.child(request.entityName).child(remoteId).observeSingleEvent(
                of: FIRDataEventType.value,
                with: { [weak self] snapshot in
                    
                    counter = NSNumber(integerLiteral: counter.intValue - 1)
                    result[remoteId] = snapshot.value
                    
                    if counter.intValue == 0 {
                        self?.completion(result)
                        self?.finish()
                    }
            })
        }
    }
}
*/
