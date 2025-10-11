import SwiftUI

// Temporary compatibility to avoid breaking incremental refactor
extension Color {
    static func named(_ name: String, fallback: Color = .blue) -> Color {
        // SwiftUI's Color init does not return optional; emulate fallback via asset existence assumptions
        // Using opacity(1) to force materialization and keep API uniform
        return Color(name, bundle: .main).opacity(1)
    }

    static var darkBackground: Color { Color.named("surface/base", fallback: .black) }
    static var cardBackground: Color { Color.named("surface/card", fallback: .white) }
    static var textPrimary: Color { Color.named("text/primary", fallback: .black) }
    static var textSecondary: Color { Color.named("text/secondary", fallback: .gray) }
    static var darkOrange: Color { Color.named("primary/600", fallback: .orange) }
    static var deepMaroon: Color { Color.named("primary/700", fallback: .orange) }
    static var lightRed: Color { Color.named("error/600", fallback: .red) }
}



