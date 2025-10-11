import SwiftUI
import SwiftData

struct  SettingsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingBudgetEditModal: Bool = false
    @State private var isShowingExportModal: Bool = false
    @State private var currentBudgetAmount: Double = 0.0
    @AppStorage("colorScheme") private var colorSchemePreference: String = "dark"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                // Other Settings Options
                VStack(spacing: 0) {
                    // Set Budget Option
                    Button(action: {
                        isShowingBudgetEditModal = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.color(.primary600))
                            Text(currentBudgetAmount > 0 ? String(format: "%.2f zł", currentBudgetAmount) : "set_budget".localized(using: languageManager))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 12))
                        }
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .background(AppTheme.color(.borderMuted))
                    
                    // Export Data Option
                    Button(action: {
                        isShowingExportModal = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                                .foregroundColor(AppTheme.color(.primary600))
                            Text("export_data".localized(using: languageManager))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 12))
                        }
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .appCard()
                
                // Theme Selection Section
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(AppTheme.color(.textPrimary))
                            .font(.system(size: 16))
                        Text("Theme")
                            .font(.headline)
                            .foregroundColor(AppTheme.color(.textPrimary))
                        Spacer()
                    }

                    HStack(spacing: 0) {
                        // Dark Theme Button
                        Button(action: {
                            colorSchemePreference = "dark"
                        }) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(AppTheme.color(.textPrimary))
                                    .font(.system(size: 16))
                                Text("Dark")
                                    .foregroundColor(AppTheme.color(.textPrimary))
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.purple)
                        }
                        
                        // Light Theme Button
                        Button(action: {
                            colorSchemePreference = "light"
                        }) {
                            HStack {
                                Image(systemName: "sun.max.fill")
                                    .foregroundColor(.textPrimary)
                                    .font(.system(size: 16))
                                Text("Light")
                                    .foregroundColor(.textPrimary)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.color(.surfaceCard))
                        }
                    }
                    .background(AppTheme.color(.surfaceCard))
                    .cornerRadius(8)
                }
                .padding(.vertical, 8)
                
                // Language Selection - flags only
                VStack(spacing: 12) {
                    HStack(spacing: 30) {
                        Button(action: {
                            languageManager.updateLanguage(to: "pl")
                        }) {
                            Text("🇵🇱")
                                .font(.system(size: 50))
                        }
                        
                        Button(action: {
                            languageManager.updateLanguage(to: "en")
                        }) {
                            Text("🇬🇧")
                                .font(.system(size: 50))
                        }
                    }
                }
                .padding(.top, 4)
                }
                .padding(.horizontal)
            }
            .background(AppTheme.color(.surfaceBase))
            .background(AppTheme.color(.surfaceBase).ignoresSafeArea())
            .navigationTitle("settings".localized(using: languageManager))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Rely on navigationTitle for title; keep only close button here
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.color(.textSecondary))
                            .font(.system(size: 20))
                    }
                }
            }
            .onAppear {
                loadCurrentMonthlyBudget()
            }
        }
        .background(AppTheme.color(.surfaceBase))
        .sheet(isPresented: $isShowingBudgetEditModal) {
            BudgetEditModal(
                isPresented: $isShowingBudgetEditModal,
                currentAmount: $currentBudgetAmount,
                onSave: { newAmount in
                    saveMonthlyBudget(newAmount)
                }
            )
            .environmentObject(languageManager)
        }
        .sheet(isPresented: $isShowingExportModal) {
            ExportDataModal(
                isPresented: $isShowingExportModal,
                modelContext: modelContext
            )
            .environmentObject(languageManager)
        }
    }

    private func loadCurrentMonthlyBudget() {
        let existingBudgets = try? modelContext.fetch(FetchDescriptor<Budzet>())
        if let currentBudget = existingBudgets?.first {
            currentBudgetAmount = currentBudget.monthlyAmount
        }
    }

    private func saveMonthlyBudget(_ amount: Double) {
        // Delete existing budget if any
        let existingBudgets = try? modelContext.fetch(FetchDescriptor<Budzet>())
        existingBudgets?.forEach { modelContext.delete($0) }

        // Create new budget
        let newBudget = Budzet(monthlyAmount: amount)
        modelContext.insert(newBudget)

        try? modelContext.save()
        currentBudgetAmount = amount
    }
}
