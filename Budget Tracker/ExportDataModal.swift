import SwiftUI
import SwiftData
import PDFKit
import UniformTypeIdentifiers
import UIKit

struct ExportDataModal: View {
    @Binding var isPresented: Bool
    let modelContext: ModelContext
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var isExporting = false
    @State private var exportMessage = ""
    @State private var showExportAlert = false
    @State private var showActivitySheet = false
    @State private var activityItems: [URL] = []
    
    @Query private var expenses: [Expense]
    @Query private var customTransactions: [CustomTransaction]
    @Query private var recurringExpenses: [RecurringExpense]
    @Query private var budgets: [Budzet]
    
    private var filteredExpenses: [Expense] {
        expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
    }
    
    private var filteredCustomTransactions: [CustomTransaction] {
        // Custom transactions don't have dates, so return all
        return customTransactions
    }
    
    private var filteredRecurringExpenses: [RecurringExpense] {
        recurringExpenses.filter { expense in
            expense.createdAt >= startDate && expense.createdAt <= endDate
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                Text("export_data".localized(using: languageManager))
                    .foregroundColor(.primary)
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20)
                
                // Date Range Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("select_date_range".localized(using: languageManager))
                        .foregroundColor(.primary)
                        .font(.system(size: 18, weight: .semibold))
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("\(String(localized: "start_date")):")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .medium))
                            
                            Spacer()
                            
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("\(String(localized: "end_date")):")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .medium))
                            
                            Spacer()
                            
                            DatePicker("", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                
                // Export Options
                VStack(alignment: .leading, spacing: 16) {
                    Text("export_format".localized(using: languageManager))
                        .foregroundColor(.primary)
                        .font(.system(size: 18, weight: .semibold))
                    
                    VStack(spacing: 12) {
                        ExportOptionButton(
                            title: "pdf".localized(using: languageManager),
                            subtitle: "pdf_document_with_charts".localized(using: languageManager),
                            icon: "doc.text",
                            action: exportToPDF
                        )
                        
                        ExportOptionButton(
                            title: "excel".localized(using: languageManager),
                            subtitle: "excel_spreadsheet".localized(using: languageManager),
                            icon: "tablecells",
                            action: exportToExcel
                        )
                        
                        ExportOptionButton(
                            title: "csv".localized(using: languageManager),
                            subtitle: "csv_text_file".localized(using: languageManager),
                            icon: "doc.plaintext",
                            action: exportToCSV
                        )
                    }
                }
                
                // Export Status
                if isExporting {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("exporting".localized(using: languageManager))
                            .foregroundColor(.secondary)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.vertical, 8)
                }
                
                if !exportMessage.isEmpty {
                    Text(exportMessage)
                        .foregroundColor(.green)
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                Spacer()
                
                // Close Button
                Button("close".localized(using: languageManager)) {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.clear, lineWidth: 0)
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                )
                .padding(.vertical, 12)
                .overlay(
                    EmptyView()
                )
                .overlay(
                    Text("close".localized(using: languageManager))
                        .foregroundColor(.primary)
                        .font(.system(size: 18, weight: .bold))
                )
            }
            .padding(.horizontal, 20)
            .background(Color(.systemBackground))
        }
        .alert("export_completed".localized(using: languageManager), isPresented: $showExportAlert, actions: {
            Button("ok".localized(using: languageManager)) { }
        }, message: {
            Text(exportMessage)
        })
        .sheet(isPresented: $showActivitySheet) {
            ActivityViewController(activityItems: activityItems)
        }
    }
    
    private func exportToPDF() {
        isExporting = true
        exportMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfData = generatePDF()
            
            DispatchQueue.main.async {
                isExporting = false
                if let pdfData = pdfData {
                    let tempURL = saveToTemporaryFile(data: pdfData, filename: "raport_finansowy.pdf", utType: .pdf)
                    if let url = tempURL {
                        activityItems = [url]
                        showActivitySheet = true
                        exportMessage = "pdf_generated".localized(using: languageManager)
                    } else {
                        exportMessage = "pdf_save_error".localized(using: languageManager)
                        showExportAlert = true
                    }
                } else {
                    exportMessage = "pdf_creation_error".localized(using: languageManager)
                    showExportAlert = true
                }
            }
        }
    }
    
    private func exportToExcel() {
        isExporting = true
        exportMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let excelData = generateExcel()
            
            DispatchQueue.main.async {
                isExporting = false
                if let excelData = excelData {
                    let tempURL = saveToTemporaryFile(data: excelData, filename: "raport_finansowy.xlsx", utType: .spreadsheet)
                    if let url = tempURL {
                        activityItems = [url]
                        showActivitySheet = true
                        exportMessage = "excel_generated".localized(using: languageManager)
                    } else {
                        exportMessage = "excel_save_error".localized(using: languageManager)
                        showExportAlert = true
                    }
                } else {
                    exportMessage = "excel_creation_error".localized(using: languageManager)
                    showExportAlert = true
                }
            }
        }
    }
    
    private func exportToCSV() {
        isExporting = true
        exportMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let csvData = generateCSV()
            
            DispatchQueue.main.async {
                isExporting = false
                if let csvData = csvData {
                    let tempURL = saveToTemporaryFile(data: csvData, filename: "raport_finansowy.csv", utType: .commaSeparatedText)
                    if let url = tempURL {
                        activityItems = [url]
                        showActivitySheet = true
                        exportMessage = "csv_generated".localized(using: languageManager)
                    } else {
                        exportMessage = "csv_save_error".localized(using: languageManager)
                        showExportAlert = true
                    }
                } else {
                    exportMessage = "csv_creation_error".localized(using: languageManager)
                    showExportAlert = true
                }
            }
        }
    }
    
    private func generatePDF() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Budget Tracker",
            kCGPDFContextAuthor: "Budget Tracker App",
            kCGPDFContextTitle: "financial_report".localized(using: languageManager)
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let title = "financial_report".localized(using: languageManager)
            let dateRange = "\(formatDate(startDate)) - \(formatDate(endDate))"
            
            // Title
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ])
            
            // Date range
            dateRange.draw(at: CGPoint(x: 50, y: 80), withAttributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.gray
            ])
            
            var yPosition: CGFloat = 120
            
            // Expenses section
            if !filteredExpenses.isEmpty {
                "expenses_section".localized(using: languageManager).draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.black
                ])
                yPosition += 30
                
                for expense in filteredExpenses {
                    let expenseText = "\(expense.name) - \(String(format: "%.2f", expense.amount)) zł - \(formatDate(expense.date))"
                    expenseText.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: UIColor.black
                    ])
                    yPosition += 20
                }
                yPosition += 20
            }
            
            // Custom Transactions section
            if !filteredCustomTransactions.isEmpty {
                "custom_transactions_section".localized(using: languageManager).draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.black
                ])
                yPosition += 30
                
                for transaction in filteredCustomTransactions {
                    let transactionText = "\(transaction.name) - \(String(format: "%.2f", transaction.amount)) zł"
                    transactionText.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: UIColor.black
                    ])
                    yPosition += 20
                }
                yPosition += 20
            }
            
            // Recurring Expenses section
            if !filteredRecurringExpenses.isEmpty {
                "recurring_expenses_section".localized(using: languageManager).draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.black
                ])
                yPosition += 30
                
                for expense in filteredRecurringExpenses {
                    let expenseText = "\(expense.expenseName) - \(String(format: "%.2f", expense.setAmount)) zł"
                    expenseText.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: UIColor.black
                    ])
                    yPosition += 20
                }
            }
        }
        
        return data
    }
    
    private func generateExcel() -> Data? {
        // Simple CSV format for Excel compatibility
        return generateCSV()
    }
    
    private func generateCSV() -> Data? {
        var csvContent = "Typ,Nazwa,Kwota,Data\n"
        
        // Add expenses
        for expense in filteredExpenses {
            csvContent += "Wydatek,\"\(expense.name)\",\(String(format: "%.2f", expense.amount)),\(formatDate(expense.date))\n"
        }
        
        // Add custom transactions
        for transaction in filteredCustomTransactions {
            csvContent += "Transakcja,\"\(transaction.name)\",\(String(format: "%.2f", transaction.amount)),\n"
        }
        
        // Add recurring expenses
        for expense in filteredRecurringExpenses {
            csvContent += "Wydatek cykliczny,\"\(expense.expenseName)\",\(String(format: "%.2f", expense.setAmount)),\(formatDate(expense.createdAt))\n"
        }
        
        return csvContent.data(using: .utf8)
    }
    
    private func saveToTemporaryFile(data: Data, filename: String, utType: UTType) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ExportOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(role: .none, action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12, weight: .medium))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Activity View Controller
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ExportDataModal(
        isPresented: .constant(true),
        modelContext: try! ModelContainer(for: Expense.self, CustomTransaction.self, RecurringExpense.self, Budzet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    )
}
