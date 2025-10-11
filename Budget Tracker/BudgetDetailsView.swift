import SwiftUI
import SwiftData

struct BudgetDetailsView: View {
    @Binding var isPresented: Bool
    let remainingMonthlyBudget: Double
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.color(.surfaceBase)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("budget_details".localized(using: languageManager))
                            .foregroundColor(AppTheme.color(.textPrimary))
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.color(.textSecondary))
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Monthly Budget Section
                    VStack(spacing: 12) {
                        Text("remaining_monthly_budget".localized(using: languageManager))
                            .foregroundColor(AppTheme.color(.textSecondary))
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("\(remainingMonthlyBudget, specifier: "%.0f") zł")
                            .foregroundColor(AppTheme.color(.textPrimary))
                            .font(.system(size: 48, weight: .bold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .appCard()
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
