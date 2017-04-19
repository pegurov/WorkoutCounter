import UIKit

enum SegueId: String {
    
    case create
    case embed
    case detail
    case result
}

protocol Coordinator: class {
    func start() -> UIViewController
}
