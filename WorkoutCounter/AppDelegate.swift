import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var startingCoordinator: Coordinator!
    var coreDataStack: CoreDataStack!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        startGenericControllers()
        
        coreDataStack = CoreDataStackImp()
        
        startingCoordinator = WorkoutCoordinator(coreDataStack: coreDataStack)
        window = UIWindow()
        window?.rootViewController = startingCoordinator?.start()
        window?.makeKeyAndVisible()
        
        FIRApp.configure()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    private func startGenericControllers() {
        
        // this is needed so that these controller can 
        // be used via storyboard
        _ = UsersViewController()
        _ = WorkoutsViewController()
    }
}
