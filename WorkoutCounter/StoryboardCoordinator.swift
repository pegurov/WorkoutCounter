import UIKit
import Firebase

class StoryboardCoordinator<RootType: UIViewController> {
    
    // MARK: - Internal properties -
    let navigationController: UINavigationController?
    let rootViewController: RootType
    let storyboard: UIStoryboard
    var subscriptions: [ListenerRegistration] = []
    
    // MARK: - Init -
    init(
        storyboard: UIStoryboard,
        startInNavigation: Bool = true) {
        
        self.storyboard = storyboard
        
        if startInNavigation {
            
            navigationController = storyboard.initialNavigation
            rootViewController = navigationController!.topViewController as! RootType
            configureRootViewController(rootViewController)
        } else {
            
            navigationController = nil
            rootViewController = storyboard.instantiateViewController(
                withIdentifier: String(describing: RootType.self)
            ) as! RootType
            configureRootViewController(rootViewController)
        }
    }
    deinit {
        subscriptions.forEach { $0.remove() }
    }
    
    func configureRootViewController(_ controller: RootType) { }
}
