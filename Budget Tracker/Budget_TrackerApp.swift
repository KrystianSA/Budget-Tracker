//
//  Budget_TrackerApp.swift
//  Budget Tracker
//
//  Created by krystiansa on 24/08/2025.
//

import SwiftUI
import SwiftData
import UserNotifications
import UIKit
import SwiftUI

@main
struct Budget_TrackerApp: App {
    
    init() {
        // Request notification permissions when app launches
        requestNotificationPermissions()
        setupAppearance()
    }
    
    // Function to handle notification permission requests
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permissions granted!")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("❌ Notification permissions denied")
            }
        }
    }
    
    // Function to send daily budget notification
    static func sendDailyBudgetNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Uwaga, budżet dzienny"
        content.body = "Przekroczyłeś swój budżet na dziś!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "daily_budget_exceeded_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error sending notification: \(error.localizedDescription)")
                } else {
                    print("✅ Daily budget notification sent successfully!")
                }
            }
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
            Budzet.self,
            CustomTransaction.self,
            RecurringExpense.self,
            // TODO: placeholder for removed "Notes" module
            RollingBudget.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Comprehensive data cleanup function
    private func clearAllData(container: ModelContainer) {
        let context = container.mainContext
        
        do {
            // Delete all Expenses
            let expenseFetch = FetchDescriptor<Expense>()
            let expenses = try context.fetch(expenseFetch)
            expenses.forEach { context.delete($0) }
            
            // Delete all Budzet (Budgets)
            let budgetFetch = FetchDescriptor<Budzet>()
            let budgets = try context.fetch(budgetFetch)
            budgets.forEach { context.delete($0) }
            
            // Delete all CustomTransactions
            let customTransactionFetch = FetchDescriptor<CustomTransaction>()
            let customTransactions = try context.fetch(customTransactionFetch)
            customTransactions.forEach { context.delete($0) }
            
            // TODO: placeholder for removed "Expenses to Pay" module
            
            // Delete all RecurringExpenses
            let recurringExpenseFetch = FetchDescriptor<RecurringExpense>()
            let recurringExpenses = try context.fetch(recurringExpenseFetch)
            recurringExpenses.forEach { context.delete($0) }
            
            // TODO: placeholder for removed "Notes" module
            
            // Save all deletions
            try context.save()
            
            print("DEBUG: All SwiftData cleared successfully")
            
        } catch {
            print("DEBUG: Error clearing data: \(error)")
        }
    }

    @AppStorage("colorScheme") private var colorSchemePreference: String = "light"

    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .environmentObject(LanguageManager())
                .preferredColorScheme(.light)
                .onAppear {
                    // Clear all data on every app launch for clean testing
                    clearAllData(container: sharedModelContainer)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
