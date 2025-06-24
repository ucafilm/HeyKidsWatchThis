// EnhancedAnimations.swift - CREATED TO RESOLVE MISSING REFERENCES
// Essential animation constants and helpers

import SwiftUI

/// Enhanced animation constants and helpers
struct EnhancedAnimations {
    
    // MARK: - Standard Animation Types
    
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let quickResponse = Animation.spring(response: 0.2, dampingFraction: 0.9)
    
    // MARK: - Specialized Animations
    
    static let listItem = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let buttonPress = Animation.spring(response: 0.2, dampingFraction: 0.7)
    static let cardFlip = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let fadeInOut = Animation.easeInOut(duration: 0.25)
    
    // MARK: - Interactive Animations
    
    static func staggered(delay: Double) -> Animation {
        return Animation.spring(response: 0.5, dampingFraction: 0.8).delay(delay)
    }
    
    static func elastic(duration: Double = 0.8) -> Animation {
        return Animation.spring(response: duration, dampingFraction: 0.6)
    }
    
    static func gentleBounce() -> Animation {
        return Animation.interpolatingSpring(stiffness: 300, damping: 30)
    }
}

/// Animation timing constants
struct AnimationTiming {
    static let instant: Double = 0.0
    static let fast: Double = 0.2
    static let normal: Double = 0.3
    static let slow: Double = 0.5
    static let verySlow: Double = 0.8
}

/// Animation curve constants
struct AnimationCurves {
    static let easeIn = Animation.easeIn
    static let easeOut = Animation.easeOut
    static let easeInOut = Animation.easeInOut
    static let linear = Animation.linear
}
