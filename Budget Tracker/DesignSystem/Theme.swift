import SwiftUI
import UIKit

public enum AppTheme {
    public enum ColorToken: String {
        case primary50, primary100, primary200, primary300, primary400, primary500, primary600, primary700, primary800, primary900
        case accent500
        case success600, warning600, error600
        case textPrimary, textSecondary
        case surfaceBase, surfaceCard
        case borderMuted
    }

    public static func color(_ token: ColorToken) -> Color {
        let bundle: Bundle = {
            #if SWIFT_PACKAGE
            return Bundle.module
            #else
            return .main
            #endif
        }()

        switch token {
        case .primary50:  return Color.named("primary/50", fallback: Color(red: 0.97, green: 0.98, blue: 1.0))
        case .primary100: return Color.named("primary/100", fallback: Color(red: 0.94, green: 0.97, blue: 1.0))
        case .primary200: return Color.named("primary/200", fallback: Color(red: 0.88, green: 0.94, blue: 1.0))
        case .primary300: return Color.named("primary/300", fallback: Color(red: 0.78, green: 0.90, blue: 0.98))
        case .primary400: return Color.named("primary/400", fallback: Color(red: 0.62, green: 0.84, blue: 0.97))
        case .primary500: return Color.named("primary/500", fallback: Color(red: 0.40, green: 0.74, blue: 0.96))
        case .primary600: return Color.named("primary/600", fallback: Color(red: 0.15, green: 0.39, blue: 0.92))
        case .primary700: return Color.named("primary/700", fallback: Color(red: 0.11, green: 0.31, blue: 0.85))
        case .primary800: return Color.named("primary/800", fallback: Color(red: 0.09, green: 0.27, blue: 0.75))
        case .primary900: return Color.named("primary/900", fallback: Color(red: 0.08, green: 0.20, blue: 0.60))
        case .accent500:  return Color.named("accent/500", fallback: .orange)
        case .success600: return Color.named("success/600", fallback: .green)
        case .warning600: return Color.named("warning/600", fallback: .yellow)
        case .error600:   return Color.named("error/600", fallback: .red)
        case .textPrimary:   return Color.named("text/primary", fallback: Color(red: 0.043, green: 0.071, blue: 0.125))
        case .textSecondary:  return Color.named("text/secondary", fallback: Color(red: 0.20, green: 0.25, blue: 0.34))
        case .surfaceBase:    return Color.named("surface/base", fallback: Color(red: 0.97, green: 0.98, blue: 0.99))
        case .surfaceCard:    return Color.named("surface/card", fallback: .white)
        case .borderMuted:    return Color.named("border/muted", fallback: Color(red: 0.89, green: 0.91, blue: 0.94))
        }
    }
}

public struct CardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(16)
            .background(AppTheme.color(.surfaceCard))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.color(.borderMuted)))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

public extension View {
    func appCard() -> some View { self.modifier(CardStyle()) }
}



