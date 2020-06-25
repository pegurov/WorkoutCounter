import Foundation

struct FirebaseData {
    
    struct User: Codable {
        
        struct Goal: Codable {
            let count: Int
            let activity: String // Activity
            let createdAt: Date
        }
        
        let name: String?
        let createdAt: Date
        
        let goals: [Goal]?
    }
    
    struct Activity: Codable {
        let title: String
        
        let createdAt: Date
        let createdBy: String // User
    }

    struct Workout: Codable {
        
        struct Session: Codable {
            
            struct Set: Codable {
                let count: Int
                let createdAt: Date
            }
            
            let activity: String // Activity
            let createdAt: Date
            let sets: [Set]?
        }
        
        let createdBy: String // User
        let createdAt: Date
        let sessions: [Session]?
    }
}

final class User {
    
    final class Goal {
        
        init(firebaseData: FirebaseData.User.Goal, activity: Activity? = nil) {
            self.firebaseData = firebaseData
            self.activity = activity
        }
        
        let firebaseData: FirebaseData.User.Goal
        
        // Proxies
        var count: Int { firebaseData.count }
        
        // Dependencies
        let activity: Activity?
    }
    
    init(
        firebaseData: FirebaseData.User,
        remoteId: String)
    {
        self.firebaseData = firebaseData
        self.remoteId = remoteId
        self.goals = firebaseData.goals?.map{ Goal(firebaseData: $0) } ?? []
    }
    
    let firebaseData: FirebaseData.User
    let remoteId: String
    let goals: [Goal]
    
    // Proxies
    var name: String? { firebaseData.name }
    var createdAt: Date { firebaseData.createdAt }
}

final class Activity {
    
    init(
        firebaseData: FirebaseData.Activity,
        remoteId: String,
        createdBy: User? = nil)
    {
        self.firebaseData = firebaseData
        self.createdBy = createdBy
        self.remoteId = remoteId
    }
    
    let firebaseData: FirebaseData.Activity
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
        createdBy: User? = nil,
        sessions: [Session] = [])
    {
        self.firebaseData = firebaseData
        self.remoteId = remoteId
        self.createdBy = createdBy
        self.sessions = sessions
    }
    
    let firebaseData: FirebaseData.Workout
    let remoteId: String
    
    // Proxies
    var createdAt: Date { firebaseData.createdAt }
    
    // Dependencies
    let createdBy: User?
    let sessions: [Session]
}

extension Workout {
    final class Session {
        
        init(
            firebaseData: FirebaseData.Workout.Session,
            activity: Activity? = nil,
            goal: User.Goal? = nil)
        {
            self.firebaseData = firebaseData
            self.sets = firebaseData.sets?.map{ Set(firebaseData: $0) } ?? []
            self.activity = activity
            self.goal = goal
        }
        
        let firebaseData: FirebaseData.Workout.Session
        
        // Proxies
        var createdAt: Date { firebaseData.createdAt }
        let sets: [Set]
        
        // Dependencies
        let activity: Activity?
        let goal: User.Goal?
    }
}

extension Workout.Session {
    final class Set {
        
        init(firebaseData: FirebaseData.Workout.Session.Set) {
            self.firebaseData = firebaseData
        }
        
        let firebaseData: FirebaseData.Workout.Session.Set
        
        // Proxies
        var count: Int { firebaseData.count }
        var createdAt: Date { firebaseData.createdAt }
    }
}

/*
 Нужно научиться резолвить dependencies
 
 чтобы ты запрашивал не просто список целей, а сразу список целей с вложенными в них activity, a у тех мог в свою очередь заставить разрезолвится createdBy и тд
*/
