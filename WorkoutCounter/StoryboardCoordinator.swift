import UIKit

class StoryboardCoordinator<RootType: UIViewController> {
    
    // MARK: - Internal properties -
    let navigationController: UINavigationController?
    let rootViewController: RootType
    let storyboard: UIStoryboard
    
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
    
    func configureRootViewController(_ controller: RootType) { }
}
