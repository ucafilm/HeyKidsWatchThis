// EnhancedUIComponents.swift - SINGLE SOURCE OF TRUTH
// All UI components in one place to avoid conflicts

import SwiftUI

// MARK: - Enhanced Button Components (SINGLE DEFINITIONS)

struct EnhancedPressableButton: View {
    let title: String
    let style: EnhancedPressableButtonStyle
    let systemImage: String?
    let action: () -> Void
    
    init(
        title: String,
        style: EnhancedPressableButtonStyle,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.triggerSelection()
            action()
        }) {
            HStack(spacing: 6) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(style.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

struct EnhancedPressableButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let cornerRadius: CGFloat
    
    static let primary = EnhancedPressableButtonStyle(
        backgroundColor: .blue,
        foregroundColor: .white,
        horizontalPadding: 16,
        verticalPadding: 10,
        cornerRadius: 8
    )
    
    static let secondary = EnhancedPressableButtonStyle(
        backgroundColor: Color(.systemGray5),
        foregroundColor: .primary,
        horizontalPadding: 12,
        verticalPadding: 8,
        cornerRadius: 6
    )
}

struct EnhancedHeartButton: View {
    let isInWatchlist: Bool
    let onToggle: () -> Void
    @State private var animationTrigger = false
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.triggerImpact(style: .light)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                animationTrigger.toggle()
            }
            
            onToggle()
        }) {
            Image(systemName: isInWatchlist ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isInWatchlist ? .red : .gray)
                .scaleEffect(isInWatchlist ? 1.2 : 1.0)
                .symbolEffect(.bounce, value: animationTrigger)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
    }
}

struct EnhancedCheckmarkButton: View {
    let isWatched: Bool
    let onMarkWatched: () -> Void
    @State private var celebrationTrigger = false
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.triggerImpact(style: .medium)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                celebrationTrigger.toggle()
            }
            
            onMarkWatched()
        }) {
            Image(systemName: isWatched ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isWatched ? .green : .gray)
                .symbolEffect(.bounce.wholeSymbol, value: celebrationTrigger)
                .scaleEffect(isWatched ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isWatched ? "Mark as unwatched" : "Mark as watched")
    }
}

// MARK: - Loading Components

struct EnhancedLoadingView: View {
    let isLoading: Bool
    let message: String
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                Image(systemName: "arrow.clockwise")
                    .font(.title)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(
                        .linear(duration: 1.0)
                        .repeatForever(autoreverses: false),
                        value: rotationAngle
                    )
                    .onAppear {
                        rotationAngle = 360
                    }
                    .onDisappear {
                        rotationAngle = 0
                    }
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Filter Components

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let systemImage: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.triggerSelection()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
                    .shadow(
                        color: isSelected ? .blue.opacity(0.3) : .clear,
                        radius: isPressed ? 4 : 2,
                        x: 0,
                        y: isPressed ? 2 : 1
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - List Animation Components

struct SearchResultsContainer<Content: View>: View {
    let searchText: String
    let content: () -> Content
    
    init(searchText: String, @ViewBuilder content: @escaping () -> Content) {
        self.searchText = searchText
        self.content = content
    }
    
    var body: some View {
        content()
    }
}

struct AdvancedListTransitions {
    static func staggeredSlide(index: Int, totalItems: Int) -> AnyTransition {
        let delay = Double(index) * 0.05
        return .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)),
            removal: .move(edge: .trailing).combined(with: .opacity)
                .animation(.spring(response: 0.3, dampingFraction: 0.8))
        )
    }
}

struct EnhancedScrollView<Content: View>: View {
    let showsIndicators: Bool
    let onRefresh: (() async -> Void)?
    let content: () -> Content
    
    init(
        showsIndicators: Bool = true,
        onRefresh: (() async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.content = content
    }
    
    var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            content()
        }
        .refreshable {
            if let onRefresh = onRefresh {
                await onRefresh()
            }
        }
    }
}

// MARK: - View Extensions (Placeholder implementations)

extension View {
    func scrollBasedScale() -> some View {
        self
    }
    
    func scrollBasedOpacity() -> some View {
        self
    }
    
    func animatedListItem(index: Int, totalItems: Int) -> some View {
        self
    }
    
    func searchResultTransition() -> some View {
        self
    }
}
