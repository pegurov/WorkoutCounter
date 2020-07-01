import UIKit

final class FeedCoordinator: StoryboardCoordinator<FeedViewController> {
    
    
    private var detailCoordinator: WorkoutCoordinator?
    
    override func configureRootViewController(_ controller: FeedViewController) {
        controller.onWorkoutSelected = { [weak self] workout in
            self?.showWorkoutDetail(workout: workout)
        }
    }
    
    func showWorkoutDetail(workout: Workout) {
        detailCoordinator = WorkoutCoordinator(
            storyboard: UIStoryboard.today,
            startInNavigation: false,
            workout: workout
        )
        navigationController?.pushViewController(detailCoordinator!.rootViewController, animated: true)
    }
}
