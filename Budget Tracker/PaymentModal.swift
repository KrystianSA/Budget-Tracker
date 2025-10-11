import SwiftUI
import SwiftData

struct PaymentModal: View {
    @Binding var isPresented: Bool
    let expense: RecurringExpense
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var paymentAmount: String = ""
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
    
    
    private func addPayment() {
        // Normalize decimal separators for proper parsing
        let normalizedAmount = paymentAmount.replacingOccurrences(of: ",", with: ".")
        if let amount = Double(normalizedAmount), amount > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                // Add to existing amount spent or set as new amount
                let currentAmountSpent = expense.amountSpent ?? 0
                let newTotalAmountSpent = currentAmountSpent + amount
                
                expense.amountSpent = newTotalAmountSpent
                expense.updatedAt = Date()
                
                // Check if fully paid - automatically mark as paid when payment equals or exceeds total
                if newTotalAmountSpent >= expense.setAmount {
                    expense.isSpent = true
                    expense.amountSpent = expense.setAmount // Set to exact total amount
                }
                
                do {
                    try modelContext.save()
                    isPresented = false
                } catch {
                    print("Error adding payment: \(error)")
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("add_payment".localized(using: languageManager))
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 24))
                    }
                }
                
                // Expense info
                VStack(spacing: 12) {
                    Text(expense.expenseName)
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    Text("Kwota całkowita: \(String(format: "%.2f zł", expense.setAmount))")
                        .foregroundColor(.textSecondary)
                        .font(.system(size: 14, weight: .medium))
                    
                    if let amountSpent = expense.amountSpent, amountSpent > 0 {
                        Text("Już zapłacono: \(String(format: "%.2f zł", amountSpent))")
                            .foregroundColor(.green)
                            .font(.system(size: 14, weight: .medium))
                        
                        let remaining = expense.setAmount - amountSpent
                        Text("Pozostało: \(String(format: "%.2f zł", remaining))")
                            .foregroundColor(.darkOrange)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .padding(.vertical, 8)
                
                // Payment amount field
                VStack(alignment: .leading, spacing: 8) {
                    Text("amount".localized(using: languageManager))
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("0.00", text: $paymentAmount)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .fill(Color.cardBackground)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.deepMaroon)
                                        .offset(y: 20)
                                )
                        )
                        .onChange(of: paymentAmount) { _, newValue in
                            validateAmount(newValue)
                        }
                    
                    // Error message
                    if !isAmountValid {
                        Text("only_digits_allowed".localized(using: languageManager))
                            .foregroundColor(.red)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.leading, 4)
                    }
                    
                    // Payment completion message
                    if !paymentAmount.isEmpty, let amount = Double(paymentAmount.replacingOccurrences(of: ",", with: ".")), amount > 0 {
                        let currentAmountSpent = expense.amountSpent ?? 0
                        let newTotalAmountSpent = currentAmountSpent + amount
                        
                        if newTotalAmountSpent >= expense.setAmount {
                            Text("expense_will_be_marked_paid".localized(using: languageManager))
                                .foregroundColor(.green)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.leading, 4)
                        }
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("cancel".localized(using: languageManager))
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 16, weight: .semibold))
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
                        addPayment()
                    }) {
                        Text("add_payment".localized(using: languageManager))
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.deepMaroon)
                            )
                    }
                    .disabled(paymentAmount.isEmpty || !isAmountValid)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview
#Preview {
    PaymentModal(
        isPresented: .constant(true),
        expense: RecurringExpense(
            amountSpent: 500.0,
            expenseName: "rent",
            setAmount: 1500.0,
            displayNumber: 123
        )
    )
    .modelContainer(for: [RecurringExpense.self], inMemory: true)
}
