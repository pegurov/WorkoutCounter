import Foundation

struct FirebaseData {
    
    struct User: Codable {
        
        struct Goal: Codable {
            let count: Int
            let type: String // ActivityType
            let createdAt: Date
        }
        
        let name: String?
        let createdAt: Date
        
        let goals: [Goal]
    }
    
    struct ActivityType: Codable {
        let title: String
        
        let createdAt: Date
        let createdBy: String // User
    }

    struct Workout: Codable {
        let createdBy: String // User
        let createdAt: Date
    }
    
    struct Activity: Codable {
        let type: String // ActivityType
        let user: String // User
        
        let createdAt: Date
        let workout: String // Workout
    }
    
    struct Set: Codable {
        let count: Int
        let createdAt: Date
        
        let activity: String // Activity
    }
}

final class User {
    
    init(
        firebaseData: FirebaseData.User,
        remoteId: String)
    {
        self.firebaseData = firebaseData
        self.remoteId = remoteId
        self.goals = firebaseData.goals.map { Goal(firebaseData: $0) }
    }
    
    let firebaseData: FirebaseData.User
    let remoteId: String
    let goals: [Goal]
    
    // Proxies
    var name: String? { firebaseData.name }
    var createdAt: Date { firebaseData.createdAt }
}

final class Goal {
    
    init(firebaseData: FirebaseData.User.Goal, type: ActivityType? = nil) {
        self.firebaseData = firebaseData
        self.type = type
    }
    
    let firebaseData: FirebaseData.User.Goal
    
    // Proxies
    var count: Int { firebaseData.count }
    
    // Dependencies
    let type: ActivityType?
}

final class ActivityType {
    
    init(
        firebaseData: FirebaseData.ActivityType,
        remoteId: String,
        createdBy: User? = nil)
    {
        self.firebaseData = firebaseData
        self.createdBy = createdBy
        self.remoteId = remoteId
    }
    
    let firebaseData: FirebaseData.ActivityType
    let remoteId: String
    
    // Proxies
    var title: String { firebaseData.title }
    var createdAt: Date { firebaseData.createdAt }
    
    // Dependencies
    let createdBy: User?
}

final class Workout {
    
    init(
        firebaseData: FirebaseData.Workout,
        remoteId: String,
        createdBy: User? = nil)
    {
        self.firebaseData = firebaseData
        self.remoteId = remoteId
        self.createdBy = createdBy
    }
    
    let firebaseData: FirebaseData.Workout
    let remoteId: String
    
    // Proxies
    var createdAt: Date { firebaseData.createdAt }
    
    // Dependencies
    let createdBy: User?
}

final class Activity {
    
    init(
        firebaseData: FirebaseData.Activity,
        remoteId: String,
        user: User? = nil,
        type: ActivityType? = nil,
        workout: Workout? = nil,
        sets: [Set] = [],
        goal: Goal?)
    {
        self.firebaseData = firebaseData
        self.remoteId = remoteId
        self.user = user
        self.type = type
        self.workout = workout
        self.sets = sets
        self.goal = goal
    }
    
    let firebaseData: FirebaseData.Activity
    let remoteId: String
    
    // Proxies
    var createdAt: Date { firebaseData.createdAt }
    
    // Dependencies
    let user: User?
    let type: ActivityType?
    let workout: Workout?
    let sets: [Set]
    let goal: Goal?
    
    final class Set {
        
        init(
            firebaseData: FirebaseData.Set,
            remoteId: String)
        {
            self.firebaseData = firebaseData
            self.remoteId = remoteId
        }
        
        let firebaseData: FirebaseData.Set
        let remoteId: String
        
        // Proxies
        var count: Int { firebaseData.count }
        var createdAt: Date { firebaseData.createdAt }
    }
}




/*
 Нужно научиться резолвить dependencies
 
 чтобы ты запрашивал не просто список целей, а сразу список целей с вложенными в них workoutType, a у тех мог в свою очередь заставить разрезолвится createdBy и тд
*/
