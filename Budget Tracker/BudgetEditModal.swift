import SwiftUI

struct BudgetEditModal: View {
    @Binding var isPresented: Bool
    @Binding var currentAmount: Double
    let onSave: (Double) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var budgetAmount: String = ""
    @State private var isAmountValid: Bool = true
    @State private var isBudgetValid: Bool = true
    
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
    
    private func validateBudget(_ input: String) {
        // Normalize decimal separators for proper parsing
        let normalizedInput = input.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(normalizedInput), amount >= 30.0 else {
            isBudgetValid = false
            return
        }
        isBudgetValid = true
    }
    
    private func saveBudget() {
        let normalizedValue = budgetAmount.replacingOccurrences(of: ",", with: ".")
        if let amount = Double(normalizedValue), amount >= 30.0 {
            onSave(amount)
            isPresented = false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("set_monthly_budget".localized(using: languageManager))
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 20)
                    
                    TextField("0.00", text: $budgetAmount)
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
                        .onChange(of: budgetAmount) { _, newValue in
                            validateAmount(newValue)
                            validateBudget(newValue)
                        }
                    
                    // Error message
                    if !isAmountValid {
                        Text("Tylko cyfry, kropka lub przecinek są dozwolone.")
                            .foregroundColor(.red)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.leading, 4)
                    }
                    
                    // Budget validation error message
                    if !isBudgetValid {
                        Text("Budżet musi być większy niż 30 zł.")
                            .foregroundColor(.red)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.leading, 4)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.darkBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized(using: languageManager)) {
                        isPresented = false
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save_button".localized(using: languageManager)) {
                        saveBudget()
                    }
                    .foregroundColor(.deepMaroon)
                    .disabled(!isAmountValid || !isBudgetValid || budgetAmount.isEmpty)
                }
            }
        }
        .onAppear {
            // Initialize with current amount if available
            if currentAmount > 0 {
                budgetAmount = String(format: "%.2f", currentAmount)
            }
        }
    }
}

#Preview {
    BudgetEditModal(
        isPresented: .constant(true),
        currentAmount: .constant(1200.0),
        onSave: { _ in }
    )
}


