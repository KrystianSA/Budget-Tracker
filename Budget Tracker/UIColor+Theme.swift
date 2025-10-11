import UIKit

extension UIColor {
    static func named(_ name: String, fallback: UIColor = .systemBlue) -> UIColor {
        return UIColor(named: name, in: .main, compatibleWith: nil) ?? fallback
    }
    private static func fallbackColor(for name: String) -> UIColor {
        switch name {
        case "surface/base": return .systemBackground
        case "surface/card": return .secondarySystemBackground
        case "text/primary": return .label
        case "text/secondary": return .secondaryLabel
        case "primary/600": return .systemOrange
        case "primary/700": return .systemOrange
        case "error/600": return .systemRed
        case "success/600": return .systemGreen
        case "warning/600": return .systemYellow
        case "border/muted": return .separator
        default: return .systemBlue
        }
    }

    static func app(_ name: String) -> UIColor {
        UIColor(named: name, in: .main, compatibleWith: nil) ?? fallbackColor(for: name)
    }

    static let appPrimary: UIColor = named("primary/600", fallback: fallbackColor(for: "primary/600"))
    static let appSurface: UIColor = named("surface/base", fallback: fallbackColor(for: "surface/base"))
    static let appTextPrimary: UIColor = named("text/primary", fallback: fallbackColor(for: "text/primary"))
}



