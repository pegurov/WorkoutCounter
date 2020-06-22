import Foundation
import Firebase

enum FirebaseError: Error {
    case documentDoesNotExist
    case cannotEncodeJSONToDictionary
}

extension Firestore {
    
    // MARK: - Getting objects
    func getObject<T: Codable>(
        id: String,
        completion: @escaping (Result<T, Error>) -> ())
    {
        collection("\(T.self)").document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let json = document?.data() else {
                completion(.failure(FirebaseError.documentDoesNotExist))
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let decoder = JSONDecoder()
                let returnValue: T = try decoder.decode(T.self, from: data)
                completion(.success(returnValue))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getObjects<T: Codable>(
        query: ((CollectionReference) -> (Query))? = nil,
        onUpdate: @escaping (Result<[T], Error>) -> ())
        -> ListenerRegistration
    {
        
        let snapshotHandler: FIRQuerySnapshotBlock = { snapshot, error in
            if let error = error {
                onUpdate(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                onUpdate(.failure(FirebaseError.documentDoesNotExist))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result: [T] = try documents.compactMap {
                    let data = try JSONSerialization.data(withJSONObject: $0.data())
                    return try decoder.decode(T.self, from: data)
                }
                onUpdate(.success(result))
            } catch {
                onUpdate(.failure(error))
            }
        }
        if let query = query {
            return query(collection("\(T.self)")).addSnapshotListener(snapshotHandler)
        } else {
            return collection("\(T.self)").addSnapshotListener(snapshotHandler)
        }
    }
    
    // MARK: - Storing objects
    func store<T: Codable>(
        object: T,
        underId id: String? = nil,
        completion: @escaping (Result<T, Error>) -> ())
    {
        let collectionName = "\(T.self)"
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            let jsonAny = try JSONSerialization.jsonObject(with: data, options: [])
            guard let json = jsonAny as? [String: Any] else {
                completion(.failure(FirebaseError.cannotEncodeJSONToDictionary))
                return
            }
            
            if let id = id {
                collection(collectionName).document(id).setData(json, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(object))
                    }
                }
            } else {
                collection(collectionName).addDocument(data: json) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(object))
                    }
                }
            }
            
        } catch {
            completion(.failure(error))
        }
    }
}
