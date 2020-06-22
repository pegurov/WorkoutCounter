import Foundation
//
//struct Dependency {
//    enum Type {
//        case toOne
//        case toMany
//    }
//
//}
//
//indirect enum Dependencies {
//    case root([Dependency])
//    case node(Dependencies)
//}
//
//struct Dependency<Type, FieldType> {
//    let keyPath: KeyPath<Type, FieldType>
////
////
////    func test() {
////        (\User.createdAt).
////    }
//}

//final class User1: NSObject, Codable {
//    let name: String
//    
//    let createdAt: Date
//    let createdBy: String // User
//}



final class User: NSObject, Codable {
    let name: String
    
    let createdAt: Date
    let createdBy: String
    
    init(
        name: String,
        createdAt: Date,
        createdBy: String)
    {
        self.name = name
        self.createdAt = createdAt
        self.createdBy = createdBy
        
        
        
        ObjectGraphNode(children: [
            ObjectGraphNode(mode: .leaf(key: "createdBy", type: User.self))
        ])
    }
}

final class ObjectGraphNode<T: Codable> {
    
    enum Mode<T> {
        case root(type: T.Type)
        case leaf(key: String, type: T.Type)
        
//        static func ==( _ lhs: Mode, rhs: Mode) -> Bool {
//            switch (lhs, rhs) {
//            case (.root, .root):
//                return true
//            case (.leaf(let lhs), .leaf(let rhs)):
//                return lhs == rhs
//            default:
//                return false
//            }
//        }
    }
    let mode: Mode<T>
    let children: [ObjectGraphNode]
    
    init(mode: Mode<T> = .root(type: T.self),
         children: [ObjectGraphNode] = []) {
        
        self.mode = mode
        self.children = children
    }
}











//struct Dependency<T> {
//    let key: String
//    let type: T.Type
//}
//
//indirect enum Dependencies {
//
//}
//
//struct DependencyResolver {
//    let users: [String: User] = [:]
//}
//
//extension User {
//
//}

//struct GlobalStorage {
//    static let users: [String: User] = [:]
//}
//
//extension User {
//}

struct WorkoutType: Codable {
    let title: String
    
    let createdAt: Date
    let createdBy: String // User
}

struct Goal: Codable {
    let count: Int
    let type: String // WorkoutType
    let user: String // User
    
    let createdAt: Date
    let createdBy: String // User
}

/*
 
 Нужно научиться резолвить dependencies
 
 чтобы ты запрашивал не просто список целей, а сразу список целей с вложенными в них workoutType, a у тех мог в свою очередь заставить разрезолвится createdBy и тд
 
 */
