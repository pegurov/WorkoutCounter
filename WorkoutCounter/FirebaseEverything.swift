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
        completion: @escaping (Result<(String, T), Error>) -> ())
        -> ListenerRegistration
    {
        return collection("\(T.self)").document(id).addSnapshotListener { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard
                let document = document,
                let json = document.data()
            else {
                completion(.failure(FirebaseError.documentDoesNotExist))
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let returnValue: T = try decoder.decode(T.self, from: data)
                completion(.success((document.documentID, returnValue)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getObjectOnce<T: Codable>(
        id: String,
        completion: @escaping (Result<(String, T), Error>) -> ())
    {
        return collection("\(T.self)").document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard
                let document = document,
                let json = document.data()
            else {
                completion(.failure(FirebaseError.documentDoesNotExist))
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let returnValue: T = try decoder.decode(T.self, from: data)
                completion(.success((document.documentID, returnValue)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getObjects<T: Codable>(
        query: ((CollectionReference) -> (Query))? = nil,
        onUpdate: @escaping (Result<[(String, T)], Error>) -> ())
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
                decoder.dateDecodingStrategy = .secondsSince1970
                let result: [(String, T)] = try documents.compactMap {
                    let data = try JSONSerialization.data(withJSONObject: $0.data())
                    let decodedObject = try decoder.decode(T.self, from: data)
                    return ($0.documentID, decodedObject)
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
    
    func getObjectsOnce<T: Codable>(
        query: ((CollectionReference) -> (Query))? = nil,
        completion: @escaping (Result<[(String, T)], Error>) -> ())
    {
        
        let snapshotHandler: FIRQuerySnapshotBlock = { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.failure(FirebaseError.documentDoesNotExist))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let result: [(String, T)] = try documents.compactMap {
                    let data = try JSONSerialization.data(withJSONObject: $0.data())
                    let decodedObject = try decoder.decode(T.self, from: data)
                    return ($0.documentID, decodedObject)
                }
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        if let query = query {
            return query(collection("\(T.self)")).getDocuments(completion: snapshotHandler)
        } else {
            return collection("\(T.self)").getDocuments(completion: snapshotHandler)
        }
    }
    
    // MARK: - Storing objects
    func upload<T: Codable>(
        object: T,
        underId id: String? = nil,
        completion: @escaping (Result<(String, T), Error>) -> ())
    {
        let collectionName = "\(T.self)"
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
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
                        completion(.success((id, object)))
                    }
                }
            } else {
                var documentId: String = ""
                let something = collection(collectionName).addDocument(data: json) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success((documentId, object)))
                    }
                }
                documentId = something.documentID
            }
            
        } catch {
            completion(.failure(error))
        }
    }
}
