// HapticFeedbackManager.swift - CRITICAL FIX with UIKit Import
// Single source of truth for haptic feedback

import UIKit
import SwiftUI

/// Manages haptic feedback throughout the app
/// Thread-safe and accessibility-compliant implementation
final class HapticFeedbackManager {
    
    // MARK: - Singleton
    static let shared = HapticFeedbackManager()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Interface
    
    /// Triggers selection haptic feedback
    func triggerSelection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    /// Triggers impact haptic feedback with specified style
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
    /// Triggers success notification haptic
    func triggerSuccess() {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    /// Triggers error notification haptic
    func triggerError() {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    /// Triggers warning notification haptic
    func triggerWarning() {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}
