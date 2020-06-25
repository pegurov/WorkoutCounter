import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootCoordinator: RootCoordinator!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {   
        FirebaseApp.configure()
        startGenericControllers()
        
        window = UIWindow()
        rootCoordinator = RootCoordinator(
            authProvider: FirebaseAuthProvider(),
            window: window!
        )
        window?.makeKeyAndVisible()
        return true
    }
}
