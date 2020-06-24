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
    private let todayCoordinator: TodayCoordinator
    private let feedCoordinator: FeedCoordinator
    private let profileCoordinator: ProfileCoordinator
    
    init(authProvider: AuthProvider, startWithProfile: Bool) {
        guard let user = authProvider.firebaseUser else { fatalError() }
        
        todayCoordinator = TodayCoordinator(
            storyboard: .today,
            startInNavigation: true,
            userId: user.uid
        )
        
        feedCoordinator = FeedCoordinator(
            storyboard: .feed,
            startInNavigation: true
        )
        
        profileCoordinator = ProfileCoordinator(
            storyboard: .profile,
            startInNavigation: true,
            userId: authProvider.firebaseUser!.uid
        )
        
        rootViewController.viewControllers = [
            todayCoordinator.navigationController!,
            feedCoordinator.navigationController!,
            profileCoordinator.navigationController!
        ]
        if startWithProfile {
            rootViewController.selectedIndex = (rootViewController.viewControllers?.count ?? 1) - 1
        }
    }
}
