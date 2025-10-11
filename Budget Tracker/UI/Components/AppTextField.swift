import SwiftUI

struct AppTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.plain)
            .padding(12)
            .background(AppTheme.color(.surfaceCard))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.color(.borderMuted)))
            .cornerRadius(12)
            .font(.body)
            .foregroundColor(AppTheme.color(.textPrimary))
    }
}



