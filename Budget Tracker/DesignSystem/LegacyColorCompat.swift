import SwiftUI

// Temporary compatibility to avoid breaking incremental refactor
extension Color {
    private static var resourceBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return .main
        #endif
    }

    static var darkBackground: Color { Color("surface/base", bundle: resourceBundle) }
    static var cardBackground: Color { Color("surface/card", bundle: resourceBundle) }
    static var textPrimary: Color { Color("text/primary", bundle: resourceBundle) }
    static var textSecondary: Color { Color("text/secondary", bundle: resourceBundle) }
    static var darkOrange: Color { Color("primary/600", bundle: resourceBundle) }
    static var deepMaroon: Color { Color("primary/700", bundle: resourceBundle) }
    static var lightRed: Color { Color("error/600", bundle: resourceBundle) }
}



