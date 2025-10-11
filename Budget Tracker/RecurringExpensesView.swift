import SwiftUI
import SwiftData

struct RecurringExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var languageManager: LanguageManager
    @Query(sort: \RecurringExpense.createdAt, order: .reverse) private var recurringExpenses: [RecurringExpense]
    @State private var showingAddExpense = false
    @State private var showingEditExpense = false
    @State private var expenseToEdit: RecurringExpense?
    @State private var showingPaymentModal = false
    @State private var expenseForPayment: RecurringExpense?
    @State private var showingDeleteAlert = false
    @State private var expenseToDelete: RecurringExpense?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("recurring_expenses".localized(using: languageManager))
                                    .foregroundColor(.textPrimary)
                                    .font(.system(size: 28, weight: .bold))
                                
                                Text("manage_recurring_expenses".localized(using: languageManager))
                                    .foregroundColor(.textSecondary)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddExpense = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.deepMaroon)
                                    .font(.system(size: 24))
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    // Expenses List
                    if recurringExpenses.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 48))
                            
                            Text("no_recurring_expenses".localized(using: languageManager))
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("add_first_recurring_expense".localized(using: languageManager))
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 14, weight: .regular))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.darkBackground)
                        .padding(.top, 24)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(recurringExpenses) { expense in
                                    CondensedExpenseCardView(expense: expense)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddExpense) {
            AddRecurringExpenseModal(
                isPresented: $showingAddExpense,
                modelContext: modelContext
            )
        }
        .sheet(isPresented: $showingEditExpense) {
            if let expenseToEdit = expenseToEdit {
                EditRecurringExpenseModal(
                    isPresented: $showingEditExpense,
                    expense: expenseToEdit,
                    modelContext: modelContext
                )
            }
        }
        .sheet(isPresented: $showingPaymentModal) {
            if let expenseForPayment = expenseForPayment {
                PaymentModal(
                    isPresented: $showingPaymentModal,
                    expense: expenseForPayment
                )
            }
        }
        .alert("delete_expense".localized(using: languageManager), isPresented: $showingDeleteAlert) {
            Button("cancel".localized(using: languageManager), role: .cancel) { }
            Button("delete".localized(using: languageManager), role: .destructive) {
                if let expenseToDelete = expenseToDelete {
                    deleteExpense(expenseToDelete)
                }
            }
        } message: {
            if let expenseToDelete = expenseToDelete {
                Text("Czy na pewno chcesz usunąć wydatek \"\(expenseToDelete.expenseName)\"?")
            }
        }
    }
    
    private func markAsPaid(_ expense: RecurringExpense) {
        withAnimation(.easeInOut(duration: 0.3)) {
            expense.isSpent = true
            expense.amountSpent = expense.setAmount
            expense.updatedAt = Date()
            
            do {
                try modelContext.save()
            } catch {
                print("Error marking expense as paid: \(error)")
            }
        }
    }
    
    private func markAsUnpaid(_ expense: RecurringExpense) {
        withAnimation(.easeInOut(duration: 0.3)) {
            expense.isSpent = false
            expense.amountSpent = nil
            expense.updatedAt = Date()
            
            do {
                try modelContext.save()
            } catch {
                print("Error marking expense as unpaid: \(error)")
            }
        }
    }
    
    private func deleteExpense(_ expense: RecurringExpense) {
        withAnimation(.easeInOut(duration: 0.3)) {
            modelContext.delete(expense)
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting recurring expense: \(error)")
            }
        }
    }
}

// MARK: - Condensed Expense Card View
struct CondensedExpenseCardView: View {
    let expense: RecurringExpense
    @EnvironmentObject var languageManager: LanguageManager
    
    private var progressPercentage: Double {
        guard let amountSpent = expense.amountSpent, amountSpent > 0 else { return 0.0 }
        return min(amountSpent / expense.setAmount, 1.0)
    }
    
    var body: some View {
        NavigationLink(destination: RecurringExpenseDetailView(expense: expense)) {
            VStack(spacing: 12) {
                // Header row with name and status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(expense.expenseName)
                                .foregroundColor(.textPrimary)
                                .font(.system(size: 16, weight: .semibold))
                                .lineLimit(1)
                            
                            if let displayNumber = expense.displayNumber {
                                Text("\(displayNumber)")
                                    .foregroundColor(.textSecondary)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.textSecondary.opacity(0.2))
                                    )
                            }
                        }
                        
                        Text(String(format: "%.2f zł", expense.setAmount))
                            .foregroundColor(.darkOrange)
                            .font(.system(size: 14, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    if expense.isSpent {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                    } else if let amountSpent = expense.amountSpent, amountSpent > 0 {
                        Text(String(format: "%.0f%%", progressPercentage * 100))
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                
                // Progress bar (only show if not fully paid and has some progress)
                if !expense.isSpent, let amountSpent = expense.amountSpent, amountSpent > 0 {
                    VStack(spacing: 4) {
                        HStack {
                            Text("paid_amount".localized(using: languageManager))
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 12, weight: .medium))
                            
                            Spacer()
                            
                            Text(String(format: "%.2f zł", amountSpent))
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 12, weight: .medium))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.textSecondary.opacity(0.2))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.deepMaroon)
                                    .frame(width: geometry.size.width * progressPercentage, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(expense.isSpent ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recurring Expense Detail View
struct RecurringExpenseDetailView: View {
    let expense: RecurringExpense
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingEditExpense = false
    @State private var showingPaymentModal = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.textPrimary)
                                    .font(.system(size: 18, weight: .medium))
                            }
                            
                            Spacer()
                            
                            Text("expense_details".localized(using: languageManager))
                                .foregroundColor(.textPrimary)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            Button(action: {
                                showingEditExpense = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.textPrimary)
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Expense name
                        Text(expense.expenseName)
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Main card
                    VStack(spacing: 20) {
                        // Status and amount
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("total_amount".localized(using: languageManager))
                                    .foregroundColor(.textSecondary)
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text(String(format: "%.2f zł", expense.setAmount))
                                    .foregroundColor(.darkOrange)
                                    .font(.system(size: 20, weight: .bold))
                            }
                            
                            Spacer()
                            
                            if let amountSpent = expense.amountSpent, amountSpent > 0 {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("spent".localized(using: languageManager))
                                        .foregroundColor(.textSecondary)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text(String(format: "%.2f zł", amountSpent))
                                        .foregroundColor(.green)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                        }
                        
                        // Progress bar
                        if let amountSpent = expense.amountSpent, amountSpent > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("progress".localized(using: languageManager))
                                        .foregroundColor(.textSecondary)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.0f%%", (amountSpent / expense.setAmount) * 100))
                                        .foregroundColor(.textSecondary)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 8)
                                            .cornerRadius(4)
                                        
                                        Rectangle()
                                            .fill(Color.deepMaroon)
                                            .frame(width: geometry.size.width * min(amountSpent / expense.setAmount, 1.0), height: 8)
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                        
                        // Status indicator
                        HStack {
                            if expense.isSpent {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 20))
                                    
                                    Text("paid_in_full".localized(using: languageManager))
                                        .foregroundColor(.green)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "circle")
                                        .foregroundColor(.textSecondary)
                                        .font(.system(size: 20))
                                    
                                    Text("unpaid".localized(using: languageManager))
                                        .foregroundColor(.textSecondary)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                showingPaymentModal = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("add_payment".localized(using: languageManager))
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditExpense) {
            EditRecurringExpenseModal(
                isPresented: $showingEditExpense,
                expense: expense,
                modelContext: modelContext
            )
        }
        .sheet(isPresented: $showingPaymentModal) {
            PaymentModal(
                isPresented: $showingPaymentModal,
                expense: expense
            )
        }
        .alert("confirm_deletion".localized(using: languageManager), isPresented: $showingDeleteAlert) {
            Button("cancel".localized(using: languageManager), role: .cancel) { }
            Button("delete".localized(using: languageManager), role: .destructive) {
                deleteExpense()
            }
        } message: {
            Text("Czy na pewno chcesz usunąć ten wydatek cykliczny?")
        }
    }
    
    private func deleteExpense() {
        modelContext.delete(expense)
        
        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting expense: \(error)")
        }
    }
}

// MARK: - Recurring Expense Card View
struct RecurringExpenseCardView: View {
    let expense: RecurringExpense
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onPayment: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with icon and name
            HStack(spacing: 12) {
                Image(systemName: "checklist")
                    .foregroundColor(.deepMaroon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 24)
                
                Text(expense.expenseName)
                    .foregroundColor(.textPrimary)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                
                Spacer()
                
                // Status indicator
                if expense.isSpent {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.textSecondary)
                        .font(.system(size: 20))
                }
            }
            
            // Amount and payment info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("total_amount".localized(using: languageManager))
                        .foregroundColor(.textSecondary)
                        .font(.system(size: 12, weight: .medium))
                    
                    Text(String(format: "%.2f zł", expense.setAmount))
                        .foregroundColor(.darkOrange)
                        .font(.system(size: 18, weight: .bold))
                }
                
                Spacer()
                
                if let amountSpent = expense.amountSpent, amountSpent > 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("spent".localized(using: languageManager))
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 12, weight: .medium))
                        
                        Text(String(format: "%.2f zł", amountSpent))
                            .foregroundColor(.green)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            
            // Progress bar
            if let amountSpent = expense.amountSpent, amountSpent > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("progress".localized(using: languageManager))
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 12, weight: .medium))
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", (amountSpent / expense.setAmount) * 100))
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(Color.deepMaroon)
                                .frame(width: geometry.size.width * min(amountSpent / expense.setAmount, 1.0), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onPayment) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14, weight: .medium))
                        Text("add_payment".localized(using: languageManager))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.textSecondary)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.cardBackground)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.cardBackground)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .alert("confirm_deletion".localized(using: languageManager), isPresented: $showingDeleteAlert) {
            Button("cancel".localized(using: languageManager), role: .cancel) { }
            Button("delete".localized(using: languageManager), role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Czy na pewno chcesz usunąć ten wydatek cykliczny?")
        }
    }
}


#Preview {
    RecurringExpensesView()
        .modelContainer(for: RecurringExpense.self, inMemory: true)
}
