import Foundation
import SwiftData

@Model
class RollingBudget {
    var monthlyBudget: Double
    var dailyBaseAmount: Double
    
    init(monthlyBudget: Double) {
        self.monthlyBudget = monthlyBudget
        self.dailyBaseAmount = monthlyBudget / 30.0 // Assuming 30 days per month
    }
    
    func getCurrentBalance(for date: Date) -> Double {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        return dailyBaseAmount * Double(dayOfMonth)
    }
    
    func getRollingBalance(for date: Date, totalExpensesUpToDate: Double) -> Double {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        
        // Calculate the accumulated daily budget up to this day
        let accumulatedBudget = dailyBaseAmount * Double(dayOfMonth)
        
        // Subtract total expenses from the beginning of the month up to this date
        return accumulatedBudget - totalExpensesUpToDate
    }
    
    func addExpense(_ amount: Double, for date: Date) -> Double {
        let currentBalance = getCurrentBalance(for: date)
        return currentBalance - amount
    }
    
    func updateMonthlyBudget(_ newBudget: Double) {
        monthlyBudget = newBudget
        dailyBaseAmount = newBudget / 30.0
    }
}
