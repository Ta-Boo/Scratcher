import SwiftUI

struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.textSecondary)
            .background(isEnabled ? Color.accent : Color.accent.opacity(0.3))
            .opacity(configuration.isPressed ? 0.4 : 1)
            .clipShape(Capsule())
    }
}

struct SecondaryButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.accent.opacity(isEnabled ? 1 : 0.3))
            .background(Color.mainBackground)
            .opacity(configuration.isPressed ? 0.4 : 1)
            .overlay(
                Capsule()
                    .stroke(Color.accent.opacity(isEnabled ? 1 : 0.3), lineWidth: 1)
            )
    }
}

extension ButtonStyle where Self == PrimaryButton {
    static var primary: PrimaryButton { .init() }
}

extension ButtonStyle where Self == SecondaryButton {
    static var secondary: SecondaryButton { .init() }
}
