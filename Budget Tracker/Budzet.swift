import Foundation
import SwiftData

@Model
class Budzet {
    var monthlyAmount: Double
    
    init(monthlyAmount: Double = 0.0) {
        self.monthlyAmount = monthlyAmount
    }
}

