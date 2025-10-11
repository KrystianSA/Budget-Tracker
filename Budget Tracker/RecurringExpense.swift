import Foundation
import SwiftData

@Model
class RecurringExpense {
    var id: UUID
    var isSpent: Bool
    var amountSpent: Double?
    var expenseName: String
    var setAmount: Double
    var displayNumber: Int?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        isSpent: Bool = false,
        amountSpent: Double? = nil,
        expenseName: String,
        setAmount: Double,
        displayNumber: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.isSpent = isSpent
        self.amountSpent = amountSpent
        self.expenseName = expenseName
        self.setAmount = setAmount
        self.displayNumber = displayNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

