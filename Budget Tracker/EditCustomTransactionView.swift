import SwiftUI
import SwiftData

struct EditCustomTransactionView: View {
    @Binding var isPresented: Bool
    let modelContext: ModelContext
    @EnvironmentObject var languageManager: LanguageManager
    
    // The transaction to edit
    let transactionToEdit: CustomTransaction
    
    @State private var transactionName: String = ""
    @State private var transactionAmount: String = ""
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
    
    private func updateCustomTransaction() {
        // Normalize decimal separators for proper parsing
        let normalizedAmount = transactionAmount.replacingOccurrences(of: ",", with: ".")
        if let amount = Double(normalizedAmount), amount > 0, !transactionName.isEmpty {
            // Update the existing transaction
            transactionToEdit.name = transactionName
            transactionToEdit.amount = amount
            
            do {
                try modelContext.save()
                isPresented = false
            } catch {
                print("Error updating custom transaction: \(error)")
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.label).opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 24) {
                // Close button positioned at the top right
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("expense_name_label".localized(using: languageManager))
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("name_placeholder".localized(using: languageManager), text: $transactionName)
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("amount_label".localized(using: languageManager))
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("0.00", text: $transactionAmount)
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
                        .onChange(of: transactionAmount) { _, newValue in
                            validateAmount(newValue)
                        }
                    
                    // Error message
                    if !isAmountValid {
                        Text("Tylko cyfry, kropka lub przecinek są dozwolone.")
                            .foregroundColor(.red)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.leading, 4)
                    }
                }
                
                Button(action: {
                    updateCustomTransaction()
                }) {
                    Text("update".localized(using: languageManager))
                        .foregroundColor(.primary)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                        )
                }
                .disabled(transactionName.isEmpty || transactionAmount.isEmpty || !isAmountValid)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
        .onAppear {
            // Pre-populate fields with existing transaction data
            transactionName = transactionToEdit.name
            transactionAmount = String(format: "%.2f", transactionToEdit.amount)
            isAmountValid = true
        }
    }
}

#Preview {
    let sampleTransaction = CustomTransaction(name: "Sample Transaction", amount: 50.0)
    return EditCustomTransactionView(
        isPresented: .constant(true),
        modelContext: try! ModelContainer(for: CustomTransaction.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext,
        transactionToEdit: sampleTransaction
    )
}

