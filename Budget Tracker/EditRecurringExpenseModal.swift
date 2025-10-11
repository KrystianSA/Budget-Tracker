import SwiftUI
import SwiftData

struct EditRecurringExpenseModal: View {
    @Binding var isPresented: Bool
    let expense: RecurringExpense
    let modelContext: ModelContext
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var expenseName = ""
    @State private var setAmount = ""
    @State private var isAmountValid = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("edit_recurring_expense".localized(using: languageManager))
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                    
                    // Nazwa wydatku (Expense name) - Moved to top
                    VStack(alignment: .leading, spacing: 8) {
                        Text("expense_name_label".localized(using: languageManager))
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("name_placeholder".localized(using: languageManager), text: $expenseName)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 16)
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
                    
                    // Kwota (Amount)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("amount_label".localized(using: languageManager))
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("0.00", text: $setAmount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .onChange(of: setAmount) { _, newValue in
                                validateAmount(newValue)
                            }
                        
                        if !isAmountValid {
                            Text("Tylko cyfry, kropka lub przecinek są dozwolone.")
                                .foregroundColor(.red)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.leading, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // Update Button
                    Button(action: updateExpense) {
                        Text("update".localized(using: languageManager))
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.deepMaroon)
                            )
                    }
                    .disabled(expenseName.isEmpty || setAmount.isEmpty || !isAmountValid)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized(using: languageManager)) {
                        isPresented = false
                    }
                    .foregroundColor(.textSecondary)
                }
            }
            .onAppear {
                loadExpenseData()
            }
        }
    }
    
    private func loadExpenseData() {
        expenseName = expense.expenseName
        setAmount = String(format: "%.2f", expense.setAmount)
        
        // Validate the loaded data
        validateAmount(setAmount)
    }
    
    private func validateAmount(_ input: String) {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        let inputCharacterSet = CharacterSet(charactersIn: input)
        let isValidCharacters = inputCharacterSet.isSubset(of: allowedCharacters)
        
        let periodCount = input.filter { $0 == "." }.count
        let commaCount = input.filter { $0 == "," }.count
        
        let isValidFormat = periodCount <= 1 && commaCount <= 1
        
        isAmountValid = isValidCharacters && isValidFormat
    }
    
    
    private func updateExpense() {
        // Normalize decimal separators for proper parsing
        let normalizedSetAmount = setAmount.replacingOccurrences(of: ",", with: ".")
        
        guard let amount = Double(normalizedSetAmount), amount > 0 else { return }
        
        expense.expenseName = expenseName
        expense.setAmount = amount
        expense.updatedAt = Date()
        
        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error updating recurring expense: \(error)")
        }
    }
}

#Preview {
    let expense = RecurringExpense(
        isSpent: false,
        amountSpent: nil,
        expenseName: "Test Expense",
        setAmount: 100.0
    )
    
    return EditRecurringExpenseModal(
        isPresented: .constant(true),
        expense: expense,
        modelContext: try! ModelContainer(for: RecurringExpense.self).mainContext
    )
}

