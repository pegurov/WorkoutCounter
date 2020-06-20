import Foundation
import FirebaseAuth

protocol AuthProvider {
    var authorized: Bool { get }
    var onAuthStateChanged: (() -> Void)? { get set }
    func logout()
}

final class FirebaseAuthProvider: AuthProvider {
    
    // MARK: - AuthProvider -
    var onAuthStateChanged: (() -> Void)?
    var authorized: Bool {
        return (Auth.auth().currentUser != nil)
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
}
