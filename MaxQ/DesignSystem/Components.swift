import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let spacing = DesignSystem.Spacing()
        return configuration.label
            .padding(.vertical, spacing.sm)
            .padding(.horizontal, spacing.md)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.accent.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Corners.md, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let spacing = DesignSystem.Spacing()
        return configuration.label
            .padding(.vertical, spacing.sm)
            .padding(.horizontal, spacing.md)
            .background(DesignSystem.Colors.secondaryBackground.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Corners.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Corners.md, style: .continuous)
                    .stroke(DesignSystem.Colors.accent.opacity(0.3), lineWidth: 1)
            )
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing().md)
            .background(DesignSystem.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Corners.md, style: .continuous))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

extension Button {
    func primaryStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }

    func secondaryStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}
