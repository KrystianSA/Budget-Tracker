import UIKit

extension UIColor {
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

    static let appPrimary: UIColor = app("primary/600")
    static let appSurface: UIColor = app("surface/base")
    static let appTextPrimary: UIColor = app("text/primary")
}



