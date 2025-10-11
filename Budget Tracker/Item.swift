//
//  Item.swift
//  Budget Tracker
//
//  Created by krystiansa on 24/08/2025.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var name: String
    var amount: Double
    var date: Date
    
    init(name: String, amount: Double, date: Date) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.date = date
    }
}
