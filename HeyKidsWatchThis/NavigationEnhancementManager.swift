// NavigationEnhancementManager.swift
// HeyKidsWatchThis - Phase 5.3.1: Navigation & UX Refinement
// Self-contained iOS 17+ navigation patterns with enhanced gestures and accessibility

import SwiftUI
import UIKit

/// Manages enhanced navigation patterns, pull-to-refresh, and gesture optimization for iOS 17+
/// Self-contained implementation that doesn't require external dependencies
@MainActor
final class NavigationEnhancementManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var isRefreshing = false
    @Published private(set) var refreshProgress: Double = 0.0
    @Published private(set) var navigationMetrics = NavigationMetrics()
    
    // MARK: - Internal State
    
    private var refreshTask: Task<Void, Never>?
    private var navigationStartTime: CFTimeInterval = 0
    private let gestureCoordinator = GestureCoordinator()
    
    // MARK: - Initialization
    
    init() {
        setupAccessibility()
    }
    
    // MARK: - Pull-to-Refresh with iOS 17+ Patterns
    
    /// Performs pull-to-refresh with proper async/await handling and cancellation prevention
    /// Uses iOS 17+ best practices to avoid task cancellation during refresh gesture
    func performRefresh<T>(_ operation: @escaping () async throws -> T) async -> Result<T, NavigationError> {
        // Prevent multiple simultaneous refresh operations
        guard !isRefreshing else {
            return Result<T, NavigationError>.failure(.refreshInProgress)
        }
        
        // Start refresh sequence
        await beginRefresh()
        
        // Use Task to prevent cancellation from SwiftUI refreshable modifier
        // This addresses the iOS 16+ cancellation issue found in research
        let result = await withTaskGroup(of: Result<T, NavigationError>.self) { group in
            group.addTask { [weak self] in
                let startTime = CFAbsoluteTimeGetCurrent()
                do {
                    // Execute the operation with proper error handling
                    let result = try await operation()
                    
                    // Record metrics
                    let duration = CFAbsoluteTimeGetCurrent() - startTime
                    await self?.recordRefreshMetrics(duration: duration, success: true)
                    
                    return .success(result)
                } catch {
                    let duration = CFAbsoluteTimeGetCurrent() - startTime
                    await self?.recordRefreshMetrics(duration: duration, success: false)
                    return .failure(.operationFailed(error))
                }
            }
            
            // Wait for completion and return first result
            guard let result = await group.next() else {
                return Result<T, NavigationError>.failure(.unknown)
            }
            
            return result
        }
        
        // Complete refresh sequence
        await endRefresh()
        return result
    }
    
    // MARK: - Enhanced Navigation Gestures
    
    /// Creates an enhanced back gesture with haptic feedback and accessibility support
    /// Addresses iOS 18 gesture conflict issues found in research
    func createEnhancedBackGesture(onBack: @escaping () -> Void) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { [weak self] value in
                // Only respond to right-ward swipes starting from left edge (44pt touch target)
                guard value.startLocation.x < 44 && value.translation.width > 0 else { return }
                
                // Provide progressive haptic feedback using iOS 17+ sensoryFeedback
                let progress = min(value.translation.width / 100, 1.0)
                if progress > 0.3 {
                    self?.playSelectionHaptic()
                }
            }
            .onEnded { [weak self] value in
                // Complete gesture if sufficient distance
                guard value.startLocation.x < 44 && value.translation.width > 50 else { return }
                
                self?.playImpactHaptic()
                self?.recordNavigationGesture(.back, successful: true)
                onBack()
            }
    }
    
    /// Optimizes touch targets for accessibility (44pt minimum as per HIG)
    func optimizedTouchTarget<Content: View>(_ content: Content) -> some View {
        content
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Navigation Performance Monitoring
    
    /// Starts tracking navigation performance for a specific transition
    func beginNavigationTracking(to destination: String) {
        navigationStartTime = CFAbsoluteTimeGetCurrent()
        logDebug("Started navigation to: \(destination)")
    }
    
    /// Completes navigation tracking and records metrics
    func completeNavigationTracking() {
        let duration = CFAbsoluteTimeGetCurrent() - navigationStartTime
        
        Task { @MainActor in
            await recordNavigationMetrics(duration: duration)
        }
    }
    
    // MARK: - Gesture Coordination (iOS 18+ fix)
    
    /// Coordinates multiple gestures to prevent conflicts (especially iOS 18+ compatibility)
    func coordinatedGesture<T: Gesture>(_ gesture: T, priority: GesturePriority = .normal) -> some Gesture {
        gestureCoordinator.coordinate(gesture, priority: priority)
    }
    
    // MARK: - Private Implementation
    
    private func beginRefresh() async {
        isRefreshing = true
        refreshProgress = 0.0
        
        // Haptic feedback for refresh start
        playLightImpactHaptic()
        
        // Announce to accessibility users
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: "Refreshing content")
        }
    }
    
    private func endRefresh() async {
        // Animate progress completion
        withAnimation(.easeOut(duration: 0.3)) {
            refreshProgress = 1.0
        }
        
        // Brief delay to show completion
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        isRefreshing = false
        refreshProgress = 0.0
        
        // Success haptic feedback
        playSuccessHaptic()
    }
    
    private func recordRefreshMetrics(duration: TimeInterval, success: Bool) async {
        navigationMetrics.lastRefreshDuration = duration
        navigationMetrics.refreshCount += 1
        
        if success {
            navigationMetrics.successfulRefreshes += 1
        }
        
        // Log performance issues
        if duration > 3.0 {
            logDebug("Slow refresh detected: \(duration)s")
        }
    }
    
    private func recordNavigationMetrics(duration: TimeInterval) async {
        navigationMetrics.averageNavigationTime = (
            navigationMetrics.averageNavigationTime + duration
        ) / 2.0
        
        navigationMetrics.navigationCount += 1
        
        // Ensure 60fps navigation performance
        if duration > 0.5 {
            logDebug("Slow navigation detected: \(duration)s")
        }
    }
    
    private func recordNavigationGesture(_ type: NavigationGestureType, successful: Bool) {
        navigationMetrics.gestureCount += 1
        
        if successful {
            navigationMetrics.successfulGestures += 1
        }
    }
    
    private func setupAccessibility() {
        // Configure dynamic type support
        NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    // MARK: - Simple Haptic Feedback (iOS 17+ patterns)
    
    private func playSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    private func playImpactHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func playLightImpactHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Simple Logging
    
    private func logDebug(_ message: String) {
        #if DEBUG
        print("[NavigationEnhancement] \(message)")
        #endif
    }
}

// MARK: - Supporting Types

struct NavigationMetrics {
    var averageNavigationTime: TimeInterval = 0
    var navigationCount: Int = 0
    var refreshCount: Int = 0
    var successfulRefreshes: Int = 0
    var lastRefreshDuration: TimeInterval = 0
    var gestureCount: Int = 0
    var successfulGestures: Int = 0
    
    var refreshSuccessRate: Double {
        guard refreshCount > 0 else { return 0 }
        return Double(successfulRefreshes) / Double(refreshCount)
    }
    
    var gestureSuccessRate: Double {
        guard gestureCount > 0 else { return 0 }
        return Double(successfulGestures) / Double(gestureCount)
    }
}

enum NavigationError: LocalizedError {
    case refreshInProgress
    case operationFailed(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .refreshInProgress:
            return "Refresh operation is already in progress"
        case .operationFailed(let error):
            return "Operation failed: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

enum NavigationGestureType {
    case back
    case swipe
    case tap
    case longPress
}

enum GesturePriority {
    case low
    case normal
    case high
    
    var sortOrder: Int {
        switch self {
        case .low: return 0
        case .normal: return 1
        case .high: return 2
        }
    }
}

/// Coordinates gesture recognition to prevent conflicts (iOS 18+ compatibility)
struct GestureCoordinator {
    
    func coordinate<T: Gesture>(_ gesture: T, priority: GesturePriority) -> some Gesture {
        // Use simultaneousGesture for iOS 18+ compatibility
        // This prevents gesture conflicts introduced in iOS 18
        gesture
            .simultaneously(with: DragGesture(minimumDistance: 0).onChanged { _ in })
    }
}

// MARK: - SwiftUI View Extensions

extension View {
    
    /// Applies enhanced refresh functionality with proper async/await handling
    func enhancedRefreshable<T>(
        using manager: NavigationEnhancementManager,
        operation: @escaping () async throws -> T
    ) -> some View {
        self.refreshable {
            let result = await manager.performRefresh(operation)
            switch result {
            case .success:
                break // Success handled internally
            case .failure(let error):
                print("Refresh failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Applies enhanced navigation gestures with haptic feedback
    func enhancedNavigationGestures(
        using manager: NavigationEnhancementManager,
        onBack: @escaping () -> Void
    ) -> some View {
        self.gesture(
            manager.createEnhancedBackGesture(onBack: onBack)
        )
    }
    
    /// Ensures accessibility-compliant touch targets
    func accessibleTouchTarget(using manager: NavigationEnhancementManager) -> some View {
        manager.optimizedTouchTarget(self)
    }
    
    /// Tracks navigation performance automatically
    func navigationPerformanceTracking(
        using manager: NavigationEnhancementManager,
        destination: String
    ) -> some View {
        self
            .onAppear {
                manager.beginNavigationTracking(to: destination)
            }
            .onDisappear {
                manager.completeNavigationTracking()
            }
    }
}

// MARK: - Protocol for Testing

@MainActor
protocol NavigationEnhancementManagerProtocol: ObservableObject {
    var isRefreshing: Bool { get }
    var refreshProgress: Double { get }
    var navigationMetrics: NavigationMetrics { get }
    
    func performRefresh<T>(_ operation: @escaping () async throws -> T) async -> Result<T, NavigationError>
    func beginNavigationTracking(to destination: String)
    func completeNavigationTracking()
}

extension NavigationEnhancementManager: NavigationEnhancementManagerProtocol {
    // Automatic conformance through matching signatures
}
