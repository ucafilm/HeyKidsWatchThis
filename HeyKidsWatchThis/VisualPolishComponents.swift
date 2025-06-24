// VisualPolishComponents.swift - FIXED MISSING ENHANCEDBUTTON
import SwiftUI

// MARK: - Enhanced Button (MISSING COMPONENT CREATED)

struct EnhancedButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content
    
    @State private var isPressed = false
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.triggerSelection()
            action()
        }) {
            content()
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(EnhancedAnimations.buttonPress, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(EnhancedAnimations.buttonPress) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Modern Card View

struct ModernCardView<Content: View>: View {
    let content: () -> Content
    
    @State private var isHovered = false
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Material.regularMaterial)
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: isHovered ? 8 : 4,
                        x: 0,
                        y: isHovered ? 4 : 2
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(EnhancedAnimations.smooth, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Modern Loading Indicator

struct ModernLoadingIndicator: View {
    @State private var isAnimating = false
    let size: CGFloat
    
    init(size: CGFloat = 44) {
        self.size = size
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AngularGradient(
                    colors: [.blue, .purple, .blue],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 1.0).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
            }
    }
}

// MARK: - Enhanced Empty State View

struct EnhancedEmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        title: String,
        subtitle: String,
        systemImage: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
                .symbolEffect(.bounce, value: UUID())
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                EnhancedButton(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue)
                        )
                }
            }
        }
        .padding()
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let emoji: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, emoji: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.emoji = emoji
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        EnhancedButton(action: action) {
            HStack(spacing: 4) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .animation(EnhancedAnimations.smooth, value: isSelected)
    }
}
