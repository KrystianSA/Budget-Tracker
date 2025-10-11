import SwiftUI

struct BudgetEntry: Identifiable, Equatable {
    let id: UUID
    var amount: Double
    var note: String?
    var date: Date
    
    init(id: UUID = UUID(), amount: Double, note: String? = nil, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.note = note
        self.date = date
    }
}

struct BudgetSection: Identifiable, Equatable {
    let id: UUID
    var title: String
    var color: Color
    var value: Double
    var note: String?
    var history: [BudgetEntry]
    
    init(
        id: UUID = UUID(),
        title: String,
        color: Color,
        value: Double,
        note: String? = nil,
        history: [BudgetEntry] = []
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.value = value
        self.note = note
        self.history = history
    }
}


