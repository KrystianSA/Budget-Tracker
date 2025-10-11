import SwiftUI
import SwiftData

struct AddRecurringExpenseModal: View {
    @Binding var isPresented: Bool
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
                    Text("add_recurring_expense".localized(using: languageManager))
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                    
                    // Nazwa wydatku (Expense name) - Moved to top
                    VStack(alignment: .leading, spacing: 8) {
                        Text("expense_name".localized(using: languageManager))
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("expense_name".localized(using: languageManager), text: $expenseName)
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
                        Text("amount".localized(using: languageManager))
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
                            Text("only_digits_allowed".localized(using: languageManager))
                                .foregroundColor(.red)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.leading, 4)
                        }
                    }
                    
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveExpense) {
                        Text("save".localized(using: languageManager))
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
        }
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
    
    
    private func saveExpense() {
        // Normalize decimal separators for proper parsing
        let normalizedSetAmount = setAmount.replacingOccurrences(of: ",", with: ".")
        
        guard let amount = Double(normalizedSetAmount), amount > 0 else { return }
        
        let newExpense = RecurringExpense(
            isSpent: false,
            amountSpent: nil,
            expenseName: expenseName,
            setAmount: amount
        )
        
        modelContext.insert(newExpense)
        
        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error saving recurring expense: \(error)")
        }
    }
}

#Preview {
    AddRecurringExpenseModal(
        isPresented: .constant(true),
        modelContext: try! ModelContainer(for: RecurringExpense.self).mainContext
    )
}
