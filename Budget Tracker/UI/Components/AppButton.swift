import SwiftUI

enum ButtonKind { case filled, tinted, outline, destructive }

struct AppButtonStyle: ButtonStyle {
    let kind: ButtonKind
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(background(pressed))
            .foregroundColor(foreground())
            .cornerRadius(10)
            .overlay(border())
            .animation(.easeOut(duration: 0.15), value: pressed)
    }

    private func background(_ pressed: Bool) -> some ShapeStyle {
        switch kind {
        case .filled:
            return AppTheme.color(.primary600).opacity(pressed ? 0.9 : 1.0)
        case .tinted:
            return AppTheme.color(.primary100)
        case .outline, .destructive:
            return AppTheme.color(.surfaceCard)
        }
    }

    private func foreground() -> Color {
        switch kind {
        case .filled: return .white
        case .tinted: return AppTheme.color(.primary700)
        case .outline: return AppTheme.color(.primary700)
        case .destructive: return AppTheme.color(.error600)
        }
    }

    private func border() -> some View {
        switch kind {
        case .outline:
            return RoundedRectangle(cornerRadius: 10).stroke(AppTheme.color(.primary300), lineWidth: 1)
        case .destructive:
            return RoundedRectangle(cornerRadius: 10).stroke(AppTheme.color(.error600), lineWidth: 1)
        default:
            return RoundedRectangle(cornerRadius: 10).stroke(.clear, lineWidth: 0)
        }
    }
}

extension Button {
    func appButton(_ kind: ButtonKind = .filled) -> some View {
        self.buttonStyle(AppButtonStyle(kind: kind))
    }
}



