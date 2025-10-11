import SwiftUI

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
        case .primary50:  return Color("primary/50", bundle: bundle)
        case .primary100: return Color("primary/100", bundle: bundle)
        case .primary200: return Color("primary/200", bundle: bundle)
        case .primary300: return Color("primary/300", bundle: bundle)
        case .primary400: return Color("primary/400", bundle: bundle)
        case .primary500: return Color("primary/500", bundle: bundle)
        case .primary600: return Color("primary/600", bundle: bundle)
        case .primary700: return Color("primary/700", bundle: bundle)
        case .primary800: return Color("primary/800", bundle: bundle)
        case .primary900: return Color("primary/900", bundle: bundle)
        case .accent500:  return Color("accent/500", bundle: bundle)
        case .success600: return Color("success/600", bundle: bundle)
        case .warning600: return Color("warning/600", bundle: bundle)
        case .error600:   return Color("error/600", bundle: bundle)
        case .textPrimary:   return Color("text/primary", bundle: bundle)
        case .textSecondary:  return Color("text/secondary", bundle: bundle)
        case .surfaceBase:    return Color("surface/base", bundle: bundle)
        case .surfaceCard:    return Color("surface/card", bundle: bundle)
        case .borderMuted:    return Color("border/muted", bundle: bundle)
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



