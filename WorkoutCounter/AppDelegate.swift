import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var startingCoordinator: Coordinator!
    var coreDataStack: CoreDataStack!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        coreDataStack = CoreDataStackImp()
        
        startingCoordinator = UsersCoordinator(coreDataStack: coreDataStack)
        window = UIWindow()
        window?.rootViewController = startingCoordinator?.start()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
}
