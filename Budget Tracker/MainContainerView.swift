import SwiftUI

struct MainContainerView: View {
    @State private var currentIndex: Int = 0
    // TODO: placeholder for removed "Notes" module
    @EnvironmentObject var languageManager: LanguageManager
    @State private var sections: [BudgetSection] = []
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ContentView()
                    .tag(0)
                    .overlay(alignment: .trailing) { EdgeHint(direction: .right) }
                    .modifier(ParallaxEffect(index: 0, currentIndex: $currentIndex))
                
                MonthlySummaryView(sections: $sections)
                    .tag(1)
                    .overlay(alignment: .leading) { EdgeHint(direction: .left) }
                    .modifier(ParallaxEffect(index: 1, currentIndex: $currentIndex))
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

private struct ParallaxEffect: ViewModifier {
    let index: Int
    @Binding var currentIndex: Int
    
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { proxy in
                let width = proxy.size.width
                let offset = CGFloat(currentIndex - index) * -width * 0.08
                Color.clear
                    .offset(x: offset)
            })
    }
}

private struct EdgeHint: View {
    enum Direction { case left, right }
    let direction: Direction
    
    var body: some View {
        LinearGradient(
            colors: [Color(.systemBackground).opacity(0.08), .clear],
            startPoint: direction == .left ? .leading : .trailing,
            endPoint: direction == .left ? .trailing : .leading
        )
        .frame(width: 16)
        .ignoresSafeArea(edges: [.vertical])
    }
}

#Preview {
    MainContainerView()
        .environmentObject(LanguageManager())
        .modelContainer(for: [Expense.self, Budzet.self, CustomTransaction.self, RecurringExpense.self], inMemory: true)
}
