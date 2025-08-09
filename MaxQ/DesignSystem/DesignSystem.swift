//
//  DesignSystem.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import SwiftUI

enum DS {
    // MARK: - Colors
    static let bg = Color(.systemBackground)
    static let card = Color(.secondarySystemBackground)
    static let cardHover = Color(.tertiarySystemBackground)
    static let brand = Color.accentColor
    static let text = Color.primary
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    static let separator = Color(.separator)
    
    // Success/Error states
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Gradient overlays
    static let brandGradient = LinearGradient(
        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color(.secondarySystemBackground), Color(.tertiarySystemBackground)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    struct Corner { 
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let headline = Font.headline.weight(.medium)
        static let subheadline = Font.subheadline.weight(.medium)
        static let body = Font.body
        static let bodyMedium = Font.body.weight(.medium)
        static let caption = Font.caption
        static let captionMedium = Font.caption.weight(.medium)
        
        // Monospaced for numbers
        static let numbers = Font.body.monospaced()
        static let numbersLarge = Font.title3.monospaced().weight(.semibold)
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let card = Color.black.opacity(0.05)
        static let button = Color.black.opacity(0.1)
        static let modal = Color.black.opacity(0.15)
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let gentle = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.Typography.bodyMedium)
            .padding(.vertical, DS.Spacing.md)
            .padding(.horizontal, DS.Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous)
                    .fill(DS.brandGradient)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                    .shadow(color: DS.Shadow.button, radius: configuration.isPressed ? 2 : 4, y: configuration.isPressed ? 1 : 2)
            )
            .foregroundStyle(.white)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.Typography.bodyMedium)
            .padding(.vertical, DS.Spacing.md)
            .padding(.horizontal, DS.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous)
                    .fill(configuration.isPressed ? DS.cardHover : DS.card)
                    .stroke(DS.brand.opacity(0.3), lineWidth: 1.5)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            )
            .foregroundStyle(DS.brand)
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    
    init(size: CGFloat = 44) {
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(configuration.isPressed ? DS.cardHover : DS.card)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(DS.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Card Components

struct MQCard<Content: View>: View {
    let content: Content
    let elevation: CardElevation
    let padding: CGFloat
    
    enum CardElevation {
        case low, medium, high
        
        var shadow: (color: Color, radius: CGFloat, y: CGFloat) {
            switch self {
            case .low: return (DS.Shadow.card, 2, 1)
            case .medium: return (DS.Shadow.card, 4, 2)
            case .high: return (DS.Shadow.modal, 8, 4)
            }
        }
    }
    
    init(elevation: CardElevation = .low, padding: CGFloat = DS.Spacing.lg, @ViewBuilder content: () -> Content) {
        self.elevation = elevation
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: DS.Corner.lg, style: .continuous)
                    .fill(DS.cardGradient)
                    .shadow(
                        color: elevation.shadow.color,
                        radius: elevation.shadow.radius,
                        y: elevation.shadow.y
                    )
            )
    }
}

struct MQListRow<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.vertical, DS.Spacing.sm)
            .padding(.horizontal, DS.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous)
                    .fill(isPressed ? DS.cardHover : DS.card)
                    .scaleEffect(isPressed ? 0.998 : 1.0)
            )
            .animation(DS.Animation.quick, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {
                isPressed = true
            }, onPressingChanged: { pressing in
                isPressed = pressing
            })
    }
}

// MARK: - Legacy Card Modifier (for compatibility)
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        MQCard(elevation: .low, padding: DS.Spacing.lg) {
            content
        }
    }
}

extension View {
    /// Conditionally applies a transform to the view
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    // MARK: - Animation Helpers
    func bounceOnTap() -> some View {
        self.scaleEffect(1.0)
            .animation(DS.Animation.bouncy, value: UUID())
    }
    
    func shimmerEffect() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: DS.Corner.md)
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(45))
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: UUID())
        )
        .clipped()
    }
    
    // MARK: - Haptic Feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
    
    func hapticSuccess() -> some View {
        self.onTapGesture {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
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
    
    func iconStyle(size: CGFloat = 44) -> some View {
        self.buttonStyle(IconButtonStyle(size: size))
    }
}

// MARK: - Matched Geometry Effect Helper
struct MatchedGeometryReader<Content: View>: View {
    let namespace: Namespace.ID
    let id: AnyHashable
    let content: Content
    
    init(namespace: Namespace.ID, id: AnyHashable, @ViewBuilder content: () -> Content) {
        self.namespace = namespace
        self.id = id
        self.content = content()
    }
    
    var body: some View {
        content
            .matchedGeometryEffect(id: id, in: namespace)
    }
}

// MARK: - Loading States
struct LoadingDots: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(DS.textSecondary)
                    .scaleEffect(animating ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Empty State Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DS.Spacing.xxl) {
            VStack(spacing: DS.Spacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(DS.textTertiary)
                
                VStack(spacing: DS.Spacing.sm) {
                    Text(title)
                        .font(DS.Typography.title2)
                        .foregroundColor(DS.text)
                    
                    Text(subtitle)
                        .font(DS.Typography.body)
                        .foregroundColor(DS.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .primaryStyle()
            }
        }
        .padding(DS.Spacing.xxxl)
    }
}
