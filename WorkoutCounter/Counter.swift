import Foundation

class Counter {
    
    private(set) var number: Int
    var isReady: Bool {
        return number == 0
    }
    
    init(number: Int = 0) {
        self.number = number
    }
    
    func increment() {
        number += 1
    }
    
    func decrement() {
        number -= 1
    }
}
