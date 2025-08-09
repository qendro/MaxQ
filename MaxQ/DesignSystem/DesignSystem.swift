//
//  DesignSystem.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import SwiftUI

enum DS {
    // semantic colors
    static let bg = Color(.systemBackground)
    static let card = Color(.secondarySystemBackground)
    static let brand = Color.accentColor
    static let text = Color.primary
    static let subtle = Color.secondary

    struct Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    struct Corner { 
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
    
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline.weight(.medium)
        static let body = Font.body
        static let caption = Font.caption
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, DS.Spacing.sm)
            .padding(.horizontal, DS.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(DS.brand.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, DS.Spacing.sm)
            .padding(.horizontal, DS.Spacing.md)
            .background(DS.card.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(DS.text)
            .clipShape(RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous)
                    .stroke(DS.brand.opacity(0.3), lineWidth: 1)
            )
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DS.Spacing.md)
            .background(DS.card)
            .clipShape(RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// MARK: - Button Extensions
extension Button {
    func primaryStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}
