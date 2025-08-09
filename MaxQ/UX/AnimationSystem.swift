//
//  AnimationSystem.swift
//  MaxQ
//
//  Comprehensive animation and haptics system for delightful interactions
//

import SwiftUI

// MARK: - Animation Presets

extension Animation {
    /// Quick feedback for button presses
    static let tap = Animation.easeOut(duration: 0.15)
    
    /// Smooth state transitions
    static let stateChange = Animation.easeInOut(duration: 0.25)
    
    /// Bouncy card interactions
    static let cardBounce = Animation.spring(response: 0.4, dampingFraction: 0.7)
    
    /// Gentle list animations
    static let listItem = Animation.spring(response: 0.5, dampingFraction: 0.8)
    
    /// Chart reveal animation
    static let chartReveal = Animation.easeOut(duration: 0.8)
    
    /// Success celebration
    static let celebration = Animation.spring(response: 0.3, dampingFraction: 0.6)
}

// MARK: - Custom Transition Effects

struct SlideInFromEdge: ViewModifier {
    let edge: Edge
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: !isActive ? (edge == .leading ? -100 : edge == .trailing ? 100 : 0) : 0,
                y: !isActive ? (edge == .top ? -100 : edge == .bottom ? 100 : 0) : 0
            )
            .opacity(isActive ? 1 : 0)
    }
}

struct ScaleAndFade: ViewModifier {
    let isActive: Bool
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 : scale)
            .opacity(isActive ? 1.0 : 0.0)
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                    value: phase
                )
            )
            .onAppear {
                phase = 200
            }
    }
}

// MARK: - Interactive Elements

struct PressableCard<Content: View>: View {
    let content: Content
    let onPress: () -> Void
    
    @State private var isPressed = false
    
    init(onPress: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onPress = onPress
        self.content = content()
    }
    
    var body: some View {
        Button(action: onPress) {
            content
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .brightness(isPressed ? -0.02 : 0.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {
            onPress()
        }, onPressingChanged: { pressing in
            withAnimation(.tap) {
                isPressed = pressing
            }
        })
    }
}

struct BouncyButton<Content: View>: View {
    let content: Content
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            action()
            Haptics.select()
        }) {
            content
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, perform: {
            // Trigger action
        }, onPressingChanged: { pressing in
            withAnimation(.cardBounce) {
                isPressed = pressing
            }
        })
    }
}

// MARK: - Success Animations

struct CheckmarkAnimation: View {
    let isVisible: Bool
    @State private var checkmarkDrawn = false
    @State private var scale = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(DS.success)
                .scaleEffect(isVisible ? 1.0 : 0.0)
                .animation(.celebration, value: isVisible)
            
            Image(systemName: "checkmark")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .scaleEffect(checkmarkDrawn ? 1.2 : 0.0)
                .animation(.celebration.delay(0.1), value: checkmarkDrawn)
        }
        .frame(width: 44, height: 44)
        .onChange(of: isVisible) { _, visible in
            if visible {
                checkmarkDrawn = true
                
                // Add haptic feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    Haptics.success()
                }
                
                // Reset for next use
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    checkmarkDrawn = false
                }
            }
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            withAnimation(.chartReveal) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newProgress in
            withAnimation(.stateChange) {
                animatedProgress = newProgress
            }
        }
    }
}

// MARK: - List Animations

struct StaggeredListAppear: ViewModifier {
    let index: Int
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .modifier(ScaleAndFade(isActive: isVisible, scale: 0.8))
            .animation(
                .listItem.delay(Double(index) * 0.1),
                value: isVisible
            )
    }
}

// MARK: - Chart Animations

struct AnimatedBar: View {
    let value: Double
    let maxValue: Double
    let color: Color
    let isAnimated: Bool
    
    @State private var animatedHeight: Double = 0
    
    private var normalizedHeight: Double {
        guard maxValue > 0 else { return 0 }
        return value / maxValue
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(color)
                .frame(height: animatedHeight * 120) // Max height of 120
        }
        .onAppear {
            if isAnimated {
                withAnimation(.chartReveal) {
                    animatedHeight = normalizedHeight
                }
            } else {
                animatedHeight = normalizedHeight
            }
        }
        .onChange(of: value) { _, _ in
            withAnimation(.stateChange) {
                animatedHeight = normalizedHeight
            }
        }
    }
}

// MARK: - Loading Animations

struct PulsingDot: View {
    let delay: Double
    let color: Color
    
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(isPulsing ? 1.2 : 0.8)
            .opacity(isPulsing ? 1.0 : 0.5)
            .animation(
                .easeInOut(duration: 0.6)
                .repeatForever()
                .delay(delay),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct LoadingIndicator: View {
    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            PulsingDot(delay: 0.0, color: DS.brand)
            PulsingDot(delay: 0.2, color: DS.brand)
            PulsingDot(delay: 0.4, color: DS.brand)
        }
    }
}

// MARK: - View Extensions for Animations

extension View {
    func slideInFromEdge(_ edge: Edge, isActive: Bool) -> some View {
        modifier(SlideInFromEdge(edge: edge, isActive: isActive))
    }
    
    func scaleAndFade(isActive: Bool, scale: CGFloat = 0.8) -> some View {
        modifier(ScaleAndFade(isActive: isActive, scale: scale))
    }
    
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
    
    func staggeredAppear(index: Int, isVisible: Bool) -> some View {
        modifier(StaggeredListAppear(index: index, isVisible: isVisible))
    }
    
    func pressableCard(onPress: @escaping () -> Void) -> some View {
        PressableCard(onPress: onPress) {
            self
        }
    }
    
    func bouncyButton(action: @escaping () -> Void) -> some View {
        BouncyButton(action: action) {
            self
        }
    }
    
    // Conditional animations based on accessibility settings
    func conditionalAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V
    ) -> some View {
        Group {
            if UIAccessibility.isReduceMotionEnabled {
                self
            } else {
                self.animation(animation, value: value)
            }
        }
    }
    
    func accessibleTransition(_ transition: AnyTransition) -> some View {
        Group {
            if UIAccessibility.isReduceMotionEnabled {
                self.transition(.opacity)
            } else {
                self.transition(transition)
            }
        }
    }
}

// MARK: - Matched Geometry Helpers

struct MatchedGeometryCard<Content: View>: View {
    let id: AnyHashable
    let namespace: Namespace.ID
    let content: Content
    
    init(id: AnyHashable, in namespace: Namespace.ID, @ViewBuilder content: () -> Content) {
        self.id = id
        self.namespace = namespace
        self.content = content()
    }
    
    var body: some View {
        content
            .matchedGeometryEffect(id: id, in: namespace)
    }
}

// MARK: - Performance Optimized Animations

struct PerformantList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let content: (Data.Element) -> Content
    
    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
    
    var body: some View {
        LazyVStack(spacing: DS.Spacing.md) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .staggeredAppear(index: index, isVisible: true)
            }
        }
    }
}
