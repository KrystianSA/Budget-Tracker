//
//  ContentView.swift
//  Budget Tracker
//
//  Created by krystiansa on 24/08/2025.
//

import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Expense Block View
struct ExpenseBlockView: View {
    let expense: Expense
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isHovered = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            Text(expense.name)
                .foregroundColor(.primary)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Text("\(expense.amount, specifier: "%.2f") zł")
                .foregroundColor(.accentColor)
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            // Trigger the contextual menu instantly
            // The contextMenu will automatically appear due to the tap
        }
        .contextMenu {
            Button(action: {
                showingEditSheet = true
            }) {
                Label("edit_label".localized(using: languageManager), systemImage: "pencil.circle")
            }
            
            Button(role: .destructive, action: {
                showingDeleteAlert = true
            }) {
                Label("delete_label".localized(using: languageManager), systemImage: "trash.circle")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditExpenseSheet(
                isPresented: $showingEditSheet,
                expense: expense,
                modelContext: modelContext
            )
        }
        .alert("confirm_deletion".localized(using: languageManager), isPresented: $showingDeleteAlert) {
            Button("cancel".localized(using: languageManager), role: .cancel) { }
            Button("delete_label".localized(using: languageManager), role: .destructive) {
                deleteExpense()
            }
        } message: {
            Text("delete_confirmation_message".localized(using: languageManager))
        }
    }
    
    private func deleteExpense() {
        withAnimation(.easeInOut(duration: 0.3)) {
            modelContext.delete(expense)
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting expense: \(error)")
            }
        }
    }
}

// MARK: - Date Picker View
struct DatePickerView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .medium))
            }
            
            Spacer()
            
            Text(selectedDate, style: .date)
                .foregroundColor(.primary)
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemFill))
                )
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.clear)
    }
}

// MARK: - Budget Section View
private struct BudgetSectionView: View {
    let dailyBudget: Double
    let dailyExpenses: Double
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("money_to_spend".localized(using: languageManager))
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            Text("\(dailyBudget, specifier: "%.0f")")
                .foregroundColor(.primary)
                .font(.system(size: 48, weight: .bold))
            
            Text("\("total_expenses".localized(using: languageManager)): \(dailyExpenses, specifier: "%.0f")")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.accentColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Monthly Budget Section View
private struct MonthlyBudgetSectionView: View {
    let remainingMonthlyBudget: Double
    let dailyRollingBudget: Double
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("remaining_monthly_budget".localized(using: languageManager))
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            Text("\(remainingMonthlyBudget, specifier: "%.0f") zł")
                .foregroundColor(.primary)
                .font(.system(size: 32, weight: .bold))
            
            // Daily Rolling Budget
            VStack(spacing: 4) {
                Text("remaining_daily_budget".localized(using: languageManager))
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .medium))
                
                Text("\(dailyRollingBudget, specifier: "%.0f") zł")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Edit Expense Sheet
private struct EditExpenseSheet: View {
    @Binding var isPresented: Bool
    let expense: Expense
    let modelContext: ModelContext
    @EnvironmentObject var languageManager: LanguageManager
    @State private var expenseName: String
    @State private var expenseAmount: String
    @State private var isAmountValid: Bool = true
    
    init(isPresented: Binding<Bool>, expense: Expense, modelContext: ModelContext) {
        self._isPresented = isPresented
        self.expense = expense
        self.modelContext = modelContext
        self._expenseName = State(initialValue: expense.name)
        self._expenseAmount = State(initialValue: String(format: "%.2f", expense.amount))
    }
    
    private func validateAmount(_ input: String) {
        // Allow only digits, single period, and single comma
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        let inputCharacterSet = CharacterSet(charactersIn: input)
        
        // Check if input contains only allowed characters
        let isValidCharacters = inputCharacterSet.isSubset(of: allowedCharacters)
        
        // Check for multiple periods or commas
        let periodCount = input.filter { $0 == "." }.count
        let commaCount = input.filter { $0 == "," }.count
        
        let isValidFormat = periodCount <= 1 && commaCount <= 1
        
        isAmountValid = isValidCharacters && isValidFormat
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("edit_expense_title".localized(using: languageManager))
                .foregroundColor(.primary)
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("amount_label".localized(using: languageManager))
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("amount_placeholder".localized(using: languageManager), text: $expenseAmount)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.separator))
                                    .offset(y: 20)
                            )
                    )
                    .onChange(of: expenseAmount) { _, newValue in
                        validateAmount(newValue)
                    }
                
                // Error message
                if !isAmountValid {
                    Text("only_digits_period_comma".localized(using: languageManager))
                        .foregroundColor(.red)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.leading, 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("expense_name_label".localized(using: languageManager))
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("name_placeholder".localized(using: languageManager), text: $expenseName)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.separator))
                                    .offset(y: 20)
                            )
                    )
            }
            
            Button(action: {
                let normalizedAmount = expenseAmount.replacingOccurrences(of: ",", with: ".")
                if let amount = Double(normalizedAmount), amount > 0 {
                    expense.name = expenseName
                    expense.amount = amount
                    
                    do {
                        try modelContext.save()
                        isPresented = false
                    } catch {
                        print("Error saving expense: \(error)")
                    }
                }
            }) {
                Text("save_changes".localized(using: languageManager))
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
            }
            .disabled(expenseAmount.isEmpty || expenseName.isEmpty || !isAmountValid)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .presentationDetents([.medium])
    }
}

// MARK: - Add Expense Sheet
private struct AddExpenseSheet: View {
    @Binding var isPresented: Bool
    let modelContext: ModelContext
    let selectedDate: Date
    let onTransactionAdded: (() -> Void)?
    let onRollingBudgetUpdate: (Double) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var isAmountValid: Bool = true
    
    private func validateAmount(_ input: String) {
        // Allow only digits, single period, and single comma
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        let inputCharacterSet = CharacterSet(charactersIn: input)
        
        // Check if input contains only allowed characters
        let isValidCharacters = inputCharacterSet.isSubset(of: allowedCharacters)
        
        // Check for multiple periods or commas
        let periodCount = input.filter { $0 == "." }.count
        let commaCount = input.filter { $0 == "," }.count
        
        let isValidFormat = periodCount <= 1 && commaCount <= 1
        
        isAmountValid = isValidCharacters && isValidFormat
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("add_expense_title".localized(using: languageManager))
                .foregroundColor(.primary)
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("amount_label".localized(using: languageManager))
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("amount_placeholder".localized(using: languageManager), text: $expenseAmount)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.separator))
                                    .offset(y: 20)
                            )
                    )
                    .onChange(of: expenseAmount) { _, newValue in
                        validateAmount(newValue)
                    }
                
                // Error message
                if !isAmountValid {
                    Text("only_digits_period_comma".localized(using: languageManager))
                        .foregroundColor(.red)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.leading, 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("expense_name_optional".localized(using: languageManager))
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("name_placeholder".localized(using: languageManager), text: $expenseName)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.separator))
                                    .offset(y: 20)
                            )
                    )
            }
            
            Button(action: {
                let normalizedAmount = expenseAmount.replacingOccurrences(of: ",", with: ".")
                if let amount = Double(normalizedAmount), amount > 0 {
                    let newExpense = Expense(
                        name: expenseName.isEmpty ? "expense_default_name".localized(using: languageManager) : expenseName,
                        amount: amount,
                        date: selectedDate
                    )
                    modelContext.insert(newExpense)
                    
                    // Update rolling budget
                    onRollingBudgetUpdate(amount)
                    
                    onTransactionAdded?()
                    isPresented = false
                    expenseName = ""
                    expenseAmount = ""
                }
            }) {
                Text("save_button".localized(using: languageManager))
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
            }
            .disabled(expenseAmount.isEmpty || !isAmountValid)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .presentationDetents([.medium])
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var languageManager: LanguageManager
    @Query private var expenses: [Expense]
    @Query private var budgets: [Budzet]
    @Query private var customTransactions: [CustomTransaction]
    @Query private var rollingBudgets: [RollingBudget]
    @State private var selectedDate = Date()
    @State private var showingAddExpense = false
    @State private var showingRecurringExpenses = false
    @State private var showingMonthlyBudgetAlert = false
    @State private var showingBudgetDetails = false
    @State private var showingSettings = false
    @AppStorage("transactionsAfterOverrunCount") private var transactionsAfterOverrunCount: Int = 0
    
    
    private var rollingBudget: RollingBudget? {
        return rollingBudgets.first
    }
    
    private var baseDailyBudget: Double {
        guard let monthlyBudget = budgets.first?.monthlyAmount, monthlyBudget > 0 else {
            return 0.0 // Default to 0 when no monthly budget is set
        }
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedDate)
        let numberOfDaysInMonth = range?.count ?? 31
        
        return monthlyBudget / Double(numberOfDaysInMonth)
    }
    
    private var moneyToSpend: Double {
        // Use rolling budget if available, otherwise fall back to simple calculation
        if let rollingBudget = rollingBudget {
            let totalExpensesUpToDate = expensesUpToDate
            return rollingBudget.getRollingBalance(for: selectedDate, totalExpensesUpToDate: totalExpensesUpToDate)
        } else {
            return baseDailyBudget - dailyExpenses
        }
    }
    
    private var isDailyBudgetExceeded: Bool {
        return dailyExpenses > baseDailyBudget && baseDailyBudget > 0
    }
    
    private var isMonthlyBudgetExceeded: Bool {
        guard let monthlyBudget = budgets.first?.monthlyAmount, monthlyBudget > 0 else {
            return false
        }
        return monthlyExpenses > monthlyBudget
    }
    
    private var dailyExpenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var expensesUpToDate: Double {
        let calendar = Calendar.current
        let endOfCurrentDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
        
        return expenses.filter { expense in
            expense.date <= endOfCurrentDay
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        return expenses.filter { expense in
            let expenseDate = calendar.startOfDay(for: expense.date)
            return expenseDate >= startOfDay && expenseDate < endOfDay
        }
    }
    
    private var customTransactionCount: Int {
        return customTransactions.count
    }
    
    private var monthlyExpenses: Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfCurrentDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedDate)) ?? selectedDate
        
        return expenses.filter { expense in
            let expenseDate = calendar.startOfDay(for: expense.date)
            return expenseDate >= startOfMonth && expenseDate < endOfCurrentDay
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var remainingMonthlyBudget: Double {
        guard let monthlyBudget = budgets.first?.monthlyAmount, monthlyBudget > 0 else {
            return 0.0
        }
        return monthlyBudget - monthlyExpenses
    }
    
    private var dailyRollingBudget: Double {
        // Use rolling budget if available, otherwise fall back to simple calculation
        if let rollingBudget = rollingBudget {
            let totalExpensesUpToDate = expensesUpToDate
            return rollingBudget.getRollingBalance(for: selectedDate, totalExpensesUpToDate: totalExpensesUpToDate)
        } else {
            return baseDailyBudget - dailyExpenses
        }
    }
    
    
    
    private func handleNewTransactionAdded() {
        // Check if monthly budget is already exceeded
        if isMonthlyBudgetExceeded {
            // Increment the counter
            transactionsAfterOverrunCount += 1
        }
    }
    
    private func updateRollingBudgetForExpense(_ amount: Double) {
        // No need to update rolling budget - it's calculated on the fly
        // The rolling budget is just: dailyBaseAmount * dayOfMonth - expenses
    }
    
    private func ensureRollingBudgetExists() {
        if rollingBudget == nil, let monthlyBudget = budgets.first?.monthlyAmount, monthlyBudget > 0 {
            let newRollingBudget = RollingBudget(monthlyBudget: monthlyBudget)
            modelContext.insert(newRollingBudget)
        }
    }
    
    

    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Date Picker
                DatePickerView(selectedDate: $selectedDate)
                    .padding(.top, 20)
                
                // Budget Section
                BudgetSectionView(
                    dailyBudget: moneyToSpend,
                    dailyExpenses: dailyExpenses
                )
                .padding(.top, 20)
                .onTapGesture {
                    guard !showingBudgetDetails else { return }
                    DispatchQueue.main.async {
                        showingBudgetDetails = true
                    }
                }
                .onChange(of: dailyExpenses) { _, newValue in
                    // Check if daily budget is exceeded and send notification
                    if isDailyBudgetExceeded {
                        Budget_TrackerApp.sendDailyBudgetNotification()
                    }
                }
                
                
                // Expenses List
                ScrollView(.vertical) {
                    LazyVStack(spacing: 12) {
                        if filteredExpenses.isEmpty {
                            Text("no_expenses_today".localized(using: languageManager))
                                .foregroundColor(.secondary)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.vertical, 40)
                        } else {
                            ForEach(filteredExpenses) { expense in
                                ExpenseBlockView(expense: expense)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Bottom Navigation
                HStack(spacing: 0) {
                    // Settings button
                    Button(action: {
                        guard !showingSettings else { return }
                        DispatchQueue.main.async {
                            showingSettings = true
                        }
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
                    }
                    
                    Spacer()
                    
                    // Center + button
                    Button(action: {
                        guard !showingAddExpense else { return }
                        DispatchQueue.main.async {
                            showingAddExpense = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.accentColor)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                    
                    // Square placeholder button
                    Button(action: {
                        guard !showingRecurringExpenses else { return }
                        DispatchQueue.main.async {
                            showingRecurringExpenses = true
                        }
                    }) {
                        Image(systemName: "square")
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(Color(.secondarySystemBackground))
            }
            
            
            // Monthly Budget Panel
//            if isShowingMonthlyBudgetPanel {
//                HStack {
//                    Spacer()
//                    
//                    VStack {
//                        Text("MonthlyBudgetPanel placeholder")
//                            .foregroundColor(.white)
//                    }
//                    .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height)
//                    .background(Color.blue.opacity(0.8))
//                    .transition(
//                        AnyTransition.asymmetric(
//                            insertion: .move(edge: .trailing),
//                            removal: .move(edge: .trailing)
//                        )
//                    )
//                }
//                .animation(.easeInOut(duration: 0.3), value: isShowingMonthlyBudgetPanel)
//            }
            
            // Expenses to Pay Panel
//            if isShowingExpensesToPayPanel {
//                HStack {
//                    VStack {
//                        Text("ExpensesToPayPanel placeholder")
//                            .foregroundColor(.white)
//                    }
//                    .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height)
//                    .background(Color.green.opacity(0.8))
//                    .transition(
//                        AnyTransition.asymmetric(
//                            insertion: .move(edge: .leading),
//                            removal: .move(edge: .leading)
//                        )
//                    )
//                    
//                    Spacer()
//                }
//                .animation(.easeInOut(duration: 0.3), value: isShowingExpensesToPayPanel)
//            }
            
            
            // Monthly Budget Exceeded Alert (Full Screen)
            if showingMonthlyBudgetAlert {
                ZStack {
                    // Full screen red background
                    Color.red
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("budget_exceeded_warning".localized(using: languageManager))
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text("\(String(localized: "budget_exceeded_message")) \(abs(remainingMonthlyBudget), specifier: "%.0f") zł")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            showingMonthlyBudgetAlert = false
                        }) {
                            Text("understand_button".localized(using: languageManager))
                                .foregroundColor(.red)
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(Color(.systemBackground))
                                .cornerRadius(30)
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .animation(.easeInOut(duration: 0.4), value: showingMonthlyBudgetAlert)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseSheet(
                isPresented: $showingAddExpense,
                modelContext: modelContext,
                selectedDate: selectedDate,
                onTransactionAdded: handleNewTransactionAdded,
                onRollingBudgetUpdate: updateRollingBudgetForExpense
            )
        }
        .sheet(isPresented: $showingRecurringExpenses) {
            RecurringExpensesView()
        }
        .sheet(isPresented: $showingBudgetDetails) {
            BudgetDetailsView(
                isPresented: $showingBudgetDetails,
                remainingMonthlyBudget: remainingMonthlyBudget
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(isPresented: $showingSettings)
                .environmentObject(languageManager)
        }
        .onAppear {
            ensureRollingBudgetExists()
        }
        .onChange(of: budgets.first?.monthlyAmount) { _, newValue in
            if let newValue = newValue, newValue > 0 {
                if let rollingBudget = rollingBudget {
                    rollingBudget.updateMonthlyBudget(newValue)
                } else {
                    let newRollingBudget = RollingBudget(monthlyBudget: newValue)
                    modelContext.insert(newRollingBudget)
                }
            }
        }
    }
    

}


#Preview {
    ContentView()
        .environmentObject(LanguageManager())
        .modelContainer(for: [Expense.self, Budzet.self, CustomTransaction.self, RecurringExpense.self, RollingBudget.self], inMemory: true)
}
