import Foundation
import SwiftData

@Model
class CustomTransaction {
    var name: String
    var amount: Double
    
    init(name: String = "", amount: Double = 0.0) {
        self.name = name
        self.amount = amount
    }
}

