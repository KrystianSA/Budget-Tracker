import SwiftUI

struct MonthlySummaryView: View {
    @Binding var sections: [BudgetSection]
    @State private var showingAddSection = false
    @Namespace private var animation
    @State private var sectionToEdit: BudgetSection?
    @State private var showingDeleteAlert = false
    @State private var sectionToDelete: BudgetSection?
    @EnvironmentObject var languageManager: LanguageManager
    @State private var sectionToCalculate: BudgetSection?
    
    var body: some View {
        ZStack {
            AppTheme.color(.surfaceBase).ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Text("monthly_summary_title".localized(using: languageManager))
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                if sections.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.grid.2x2")
                            .foregroundColor(AppTheme.color(.textSecondary))
                            .font(.system(size: 40))
                        Text("no_sections_message".localized(using: languageManager))
                            .foregroundColor(AppTheme.color(.textSecondary))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(sections) { section in
                                SummaryCard(section: section, onTap: {
                                    sectionToEdit = section
                                }, onDelete: {
                                    sectionToDelete = section
                                    showingDeleteAlert = true
                                }, onCalculate: {
                                    sectionToCalculate = section
                                })
                                    .matchedGeometryEffect(id: section.id, in: animation)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                }
            }
            
            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddSection = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(AppTheme.color(.primary600)))
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingAddSection) {
            AddSectionModal(isPresented: $showingAddSection) { new in
                sections.append(new)
            }
            .environmentObject(languageManager)
        }
        .sheet(item: $sectionToEdit) { selected in
            EditSectionModal(
                isPresented: Binding(
                    get: { sectionToEdit != nil },
                    set: { newVal in if !newVal { sectionToEdit = nil } }
                ),
                section: selected,
                onSave: { updated in
                    if let idx = sections.firstIndex(where: { $0.id == updated.id }) {
                        sections[idx] = updated
                    }
                },
                isAmountLocked: !selected.history.isEmpty
            )
            .environmentObject(languageManager)
        }
        .sheet(item: $sectionToCalculate) { selected in
            CalculateSectionModal(
                isPresented: Binding(
                    get: { sectionToCalculate != nil },
                    set: { newVal in if !newVal { sectionToCalculate = nil } }
                ),
                section: selected
            ) { updated in
                if let idx = sections.firstIndex(where: { $0.id == updated.id }) {
                    sections[idx] = updated
                }
            }
            .environmentObject(languageManager)
        }
        .alert("delete_section_title".localized(using: languageManager), isPresented: $showingDeleteAlert) {
            Button("cancel".localized(using: languageManager), role: .cancel) { sectionToDelete = nil }
            Button("delete".localized(using: languageManager), role: .destructive) {
                if let toDelete = sectionToDelete {
                    sections.removeAll { $0.id == toDelete.id }
                }
                sectionToDelete = nil
            }
        } message: {
            Text("delete_section_message".localized(using: languageManager))
        }
    }
}

private struct SummaryCard: View {
    let section: BudgetSection
    var onTap: () -> Void
    var onDelete: () -> Void
    var onCalculate: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showAllHistory: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(section.title)
                    .foregroundColor(AppTheme.color(.textPrimary))
                    .font(.system(size: 16, weight: .semibold))
                Spacer(minLength: 0)
            }
            
            Text(String(format: "%.2f zł", section.value))
                .foregroundColor(AppTheme.color(.textPrimary))
                .font(.system(size: 24, weight: .bold))
            
            // Always show the base note from section creation
            if let baseNote = section.note, !baseNote.isEmpty {
                Text(baseNote)
                    .foregroundColor(AppTheme.color(.textSecondary))
                    .font(.system(size: 13, weight: .regular))
                    .padding(.top, 6)
            }

            // History list (latest first)
            if !section.history.isEmpty {
                let sorted = section.history.sorted(by: { $0.date > $1.date })
                let visible = showAllHistory ? sorted : Array(sorted.prefix(1))
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(visible) { entry in
                        HStack(spacing: 8) {
                            Text(String(format: "%@%.2f zł", entry.amount >= 0 ? "+" : "", entry.amount))
                                .foregroundColor(entry.amount >= 0 ? AppTheme.color(.success600) : AppTheme.color(.error600))
                                .font(.system(size: 13, weight: .semibold))
                            if let n = entry.note, !n.isEmpty {
                                Text("- \(n)")
                                    .foregroundColor(AppTheme.color(.textSecondary))
                                    .font(.system(size: 13, weight: .regular))
                            }
                        }
                    }
                    if sorted.count > 1 {
                        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showAllHistory.toggle() } }) {
                            Image(systemName: showAllHistory ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.color(.textSecondary))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 10) // push history a bit lower
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: onTap) {
                Label("edit".localized(using: languageManager), systemImage: "pencil")
            }
            Button(action: onCalculate) {
                Label("calculate".localized(using: languageManager), systemImage: "plus.slash.minus")
            }
            Button(role: .destructive, action: onDelete) {
                Label("delete".localized(using: languageManager), systemImage: "trash")
            }
        }
    }
}

private struct AddSectionModal: View {
    @Binding var isPresented: Bool
    var onCreate: (BudgetSection) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var title: String = ""
    @State private var value: String = ""
    @State private var note: String = ""
    @State private var selectedColor: Color = .green
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("field_title".localized(using: languageManager))
                        .foregroundColor(AppTheme.color(.textPrimary))
                    TextField("field_title_placeholder".localized(using: languageManager), text: $title)
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.color(.surfaceCard)))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("field_value".localized(using: languageManager))
                        .foregroundColor(AppTheme.color(.textPrimary))
                    TextField("0.00", text: $value)
                        .keyboardType(.decimalPad)
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.color(.surfaceCard)))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("field_note_optional".localized(using: languageManager))
                        .foregroundColor(AppTheme.color(.textPrimary))
                    TextField("...", text: $note)
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.color(.surfaceCard)))
                }
                
                // Color selection removed; default remains green
                
                Spacer()
                
                Button(action: create) {
                    Text("add_section_button".localized(using: languageManager))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .appButton(.filled)
                .disabled(title.isEmpty || Double(value.replacingOccurrences(of: ",", with: ".")) == nil)
            }
            .padding(20)
            .background(AppTheme.color(.surfaceBase).ignoresSafeArea())
            .navigationTitle("new_section_title".localized(using: languageManager))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized(using: languageManager)) { isPresented = false }
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private func create() {
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        guard let number = Double(normalized) else { return }
        let section = BudgetSection(title: title, color: selectedColor, value: number, note: note.isEmpty ? nil : note, history: [])
        onCreate(section)
        isPresented = false
    }
}
 
private struct EditSectionModal: View {
    @Binding var isPresented: Bool
    let section: BudgetSection
    var onSave: (BudgetSection) -> Void
    var isAmountLocked: Bool = false
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var title: String
    @State private var value: String
    @State private var note: String
    
    init(
        isPresented: Binding<Bool>,
        section: BudgetSection,
        onSave: @escaping (BudgetSection) -> Void,
        isAmountLocked: Bool = false
    ) {
        self._isPresented = isPresented
        self.section = section
        self.onSave = onSave
        self.isAmountLocked = isAmountLocked
        self._title = State(initialValue: section.title)
        self._value = State(initialValue: String(format: "%.2f", section.value))
        self._note = State(initialValue: section.note ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("field_title".localized(using: languageManager)).foregroundColor(AppTheme.color(.textPrimary))
                    TextField("field_title_placeholder".localized(using: languageManager), text: $title)
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.color(.surfaceCard)))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("field_value".localized(using: languageManager)).foregroundColor(AppTheme.color(.textPrimary))
                    if isAmountLocked {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppTheme.color(.textSecondary))
                                .font(.system(size: 12))
                                Text(value)
                                    .foregroundColor(AppTheme.color(.textPrimary))
                                .font(.system(size: 14))
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(AppTheme.color(.surfaceCard).opacity(0.5)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.color(.borderMuted), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        Text("amount_locked_reason".localized(using: languageManager))
                            .foregroundColor(AppTheme.color(.textSecondary))
                            .font(.system(size: 12, weight: .regular))
                    } else {
                        TextField("0.00", text: $value)
                            .keyboardType(.decimalPad)
                            .foregroundColor(AppTheme.color(.textPrimary))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(AppTheme.color(.surfaceCard)))
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("field_note_optional".localized(using: languageManager)).foregroundColor(AppTheme.color(.textPrimary))
                    TextField("...", text: $note)
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.color(.surfaceCard)))
                }
                Spacer()
                Button(action: save) {
                    Text("save".localized(using: languageManager))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .appButton(.filled)
                .disabled(title.isEmpty || Double(value.replacingOccurrences(of: ",", with: ".")) == nil || isAmountLocked)
            }
            .padding(20)
            .background(AppTheme.color(.surfaceBase).ignoresSafeArea())
            .navigationTitle("edit_section_title".localized(using: languageManager))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized(using: languageManager)) { isPresented = false }
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private func save() {
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        guard let number = Double(normalized) else { return }
        let updated = BudgetSection(id: section.id, title: title, color: section.color, value: number, note: note.isEmpty ? nil : note, history: section.history)
        onSave(updated)
        isPresented = false
    }
}

private struct CalculateSectionModal: View {
    @Binding var isPresented: Bool
    let section: BudgetSection
    var onSave: (BudgetSection) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var delta: String = ""
    @State private var mode: Mode = .add
    @State private var calcNote: String = ""
    
    enum Mode { case add, subtract }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("current_value".localized(using: languageManager))
                        .foregroundColor(AppTheme.color(.textSecondary))
                    Text(String(format: "%.2f zł", section.value))
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .font(.system(size: 22, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("change_by".localized(using: languageManager))
                        .foregroundColor(AppTheme.color(.textPrimary))
                    TextField("0.00", text: $delta)
                        .keyboardType(.decimalPad)
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.color(.surfaceCard)))
                }
                
                // Optional short note for this calculation
                VStack(alignment: .leading, spacing: 8) {
                    Text("field_note_optional".localized(using: languageManager))
                        .foregroundColor(AppTheme.color(.textPrimary))
                    TextField("...", text: $calcNote)
                        .foregroundColor(AppTheme.color(.textPrimary))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.color(.surfaceCard)))
                }

                HStack(spacing: 12) {
                    Button(action: { mode = .add }) {
                        Label("add".localized(using: languageManager), systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(mode == .add ? AppTheme.color(.primary600) : AppTheme.color(.surfaceCard)))
                    
                    Button(action: { mode = .subtract }) {
                        Label("subtract".localized(using: languageManager), systemImage: "minus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(mode == .subtract ? AppTheme.color(.primary600) : AppTheme.color(.surfaceCard)))
                }
                .foregroundColor(AppTheme.color(.textPrimary))
                
                Spacer()
                
                Button(action: applyChange) {
                    Text("save".localized(using: languageManager))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .appButton(.filled)
                .disabled(Double(delta.replacingOccurrences(of: ",", with: ".")) == nil)
            }
            .padding(20)
            .background(AppTheme.color(.surfaceBase).ignoresSafeArea())
            .navigationTitle("calculate".localized(using: languageManager))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized(using: languageManager)) { isPresented = false }
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    private func applyChange() {
        let normalized = delta.replacingOccurrences(of: ",", with: ".")
        guard let valueDelta = Double(normalized) else { return }
        let newValue = mode == .add ? section.value + valueDelta : section.value - valueDelta
        let trimmedNote = calcNote.trimmingCharacters(in: .whitespacesAndNewlines)
        var newHistory = section.history
        newHistory.insert(BudgetEntry(amount: mode == .add ? valueDelta : -valueDelta, note: trimmedNote.isEmpty ? nil : trimmedNote), at: 0)
        let updated = BudgetSection(id: section.id, title: section.title, color: section.color, value: newValue, note: section.note, history: newHistory)
        onSave(updated)
        isPresented = false
    }
}


