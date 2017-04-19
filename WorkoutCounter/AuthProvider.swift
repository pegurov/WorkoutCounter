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
        return (FIRAuth.auth()?.currentUser != nil)
    }
    
    private var handle: FirebaseAuth.FIRAuthStateDidChangeListenerHandle?
    
    init() {
        
        handle = FIRAuth.auth()?.addStateDidChangeListener() { [weak self] auth, user in
            print("changed auth state! \(auth), \(String(describing: user))")
            self?.onAuthStateChanged?()
        }
    }
    
    func logout() {
        try? FIRAuth.auth()?.signOut()
    }
}
