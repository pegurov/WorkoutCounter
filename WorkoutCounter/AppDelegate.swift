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
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        startGenericControllers()
        coreDataStack = CoreDataStackImp()
        FirebaseManager.startWith(coreDataStack: coreDataStack)
        
        let node = ObjectGraphNode(
            children: [
//                ObjectGraphNode(mode: .leaf("type")),
//                ObjectGraphNode(mode: .leaf("createdBy"))
            ]
        )
        let request = ObjectsRequest(
            entityName: "WorkoutType",
            mode: .all,
            node: node
        )
        FirebaseManager.sharedInstance.loadRequest(request, completion: {
            print("loaded request!!")
        })
        
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
        
        // this is needed so that these controller can 
        // be used via storyboard
        _ = UsersViewController()
        _ = WorkoutsViewController()
    }
}
