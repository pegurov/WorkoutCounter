import Foundation
import FirebaseAuth

protocol AuthProvider {
    var authorized: Bool { get }
    var firebaseUser: FirebaseAuth.User? { get }
    var onAuthStateChanged: (() -> Void)? { get set }
    
    func updateCurrentUser(completion: @escaping (Bool) -> ())
    func logout()
}

final class FirebaseAuthProvider: AuthProvider {
    
    // MARK: - AuthProvider -
    var onAuthStateChanged: (() -> Void)?
    var authorized: Bool {
        return firebaseUser != nil
    }
    var firebaseUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    private var handle: FirebaseAuth.AuthStateDidChangeListenerHandle?
    
    init() {
        
        handle = Auth.auth().addStateDidChangeListener() { [weak self] auth, user in
            print("changed auth state! \(auth), \(String(describing: user))")
            self?.onAuthStateChanged?()
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
    
    func updateCurrentUser(completion: @escaping (Bool) -> ()) {
        guard let user = firebaseUser else {
            assertionFailure("User not authorized")
            return
        }
        
        Auth.auth().updateCurrentUser(user) { error in
            completion(error == nil)
        }
    }
}
