import SwiftUI

struct HitTestOverlay: ViewModifier {
    let name: String
    func body(content: Content) -> some View {
        content
            .overlay(
                Color.red.opacity(0.03)
                    .accessibilityIdentifier("HitTest:\(name)")
                    .allowsHitTesting(false)
            )
    }
}

extension View {
    func debugHit(_ name: String) -> some View { self.modifier(HitTestOverlay(name: name)) }
}


