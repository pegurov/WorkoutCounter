import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: ApplicationCoordinator!
    var coreDataStack: CoreDataStack!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        BuddyBuildSDK.setup()
        
        
        FirebaseApp.configure()
        startGenericControllers()
        coreDataStack = CoreDataStackImp()
        FirebaseManager.startWith(coreDataStack: coreDataStack)
        
        window = UIWindow()
        appCoordinator = ApplicationCoordinator(
            authProvider: FirebaseAuthProvider(),
            coreDataStack: coreDataStack,
            window: window!
        )
        window?.makeKeyAndVisible()
        appCoordinator.start()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    private func startGenericControllers() {
        
        // this is needed so that these controllers can
        // be used via storyboard
        _ = UsersViewController()
        _ = WorkoutsViewController()
        _ = SessionsViewController()
    }
}
