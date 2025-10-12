import SwiftUI
import SwiftData

struct BudgetDetailsView: View {
    @Binding var isPresented: Bool
    let remainingMonthlyBudget: Double
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("budget_details".localized(using: languageManager))
                            .foregroundColor(.primary)
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Monthly Budget Section
                    VStack(spacing: 12) {
                        Text("remaining_monthly_budget".localized(using: languageManager))
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("\(remainingMonthlyBudget, specifier: "%.0f") zł")
                            .foregroundColor(.primary)
                            .font(.system(size: 48, weight: .bold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    BudgetDetailsView(
        isPresented: .constant(true),
        remainingMonthlyBudget: 1500.0
    )
    .environmentObject(LanguageManager())
}
