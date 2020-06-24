import Foundation

final class Counter {
    
    private(set) var number: Int
    private var isReady: Bool {
        return number <= 0
    }
    
    init(number: Int = 0) {
        self.number = number
    }
    
    func increment() {
        number += 1
    }
    
    func decrement(_ performIfReady: () -> ()) {
        number -= 1
        if isReady {
            performIfReady()
        }
    }
}
