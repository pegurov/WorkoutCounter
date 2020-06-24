import UIKit
import FirebaseAuth

final class ApplicationCoordinator {
    
    // тут должны быть вкладки. Начать можем с самой прростой вкладки - User
    // Открываешь app, логинишься и видишь вкладку со своим профилем (если она не заполнена)
    // Если заполнена, то тогда падаешь во вкладку Today
    
    // MARK: - Output
    let rootViewController = UITabBarController()
    var onLogout: (() -> Void)? {
        get { return profileCoordinator.onLogout }
        set { profileCoordinator.onLogout = newValue }
    }
    
    // MARK: - Private
    private let profileCoordinator: ProfileCoordinator
    private let todayCoordinator: TodayCoordinator
    
    init(authProvider: AuthProvider) {
        guard let user = authProvider.firebaseUser else { fatalError() }
        
        profileCoordinator = ProfileCoordinator(
            storyboard: .profile,
            startInNavigation: true,
            userId: authProvider.firebaseUser!.uid
        )
        
        todayCoordinator = TodayCoordinator(
            storyboard: .today,
            startInNavigation: true,
            userId: user.uid
        )
        
        rootViewController.viewControllers = [
            todayCoordinator.navigationController!,
            profileCoordinator.navigationController!
        ]
    }
}
