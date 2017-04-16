import UIKit

enum SegueId: String {
    
    case create
    case embed
    case detail
}

protocol Coordinator: class {
    func start() -> UIViewController
}
