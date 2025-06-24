// NavigationManagerProtocol.swift - FIXED: @MainActor Protocol for iOS 17+ Actor Isolation
// Research-backed solution following Apple's WWDC 2024 SwiftUI navigation guidelines

import SwiftUI
import Foundation

/// Navigation manager protocol with proper @MainActor isolation
/// 
/// RESEARCH DECISION: Protocol marked @MainActor to match implementation isolation
/// Based on Apple WWDC 2024: SwiftUI Views and navigation managers should be MainActor isolated
/// This ensures compile-time safety for UI state changes and navigation operations
@MainActor
protocol NavigationManagerProtocol: ObservableObject {
    var selectedTab: AppTab { get set }
    var movieService: MovieServiceProtocol { get }
    var memoryService: MemoryServiceProtocol { get }
    
    func navigateToTab(_ tab: AppTab)
    func navigateToMovies()
    func navigateToWatchlist()
    func navigateToMemories()
    func navigateToSettings()
    func refreshMovies() async
    func refreshMemories() async
}

/*
 ARCHITECTURAL DECISION RATIONALE:
 
 1. @MainActor Protocol Annotation:
    - Matches NavigationManager implementation isolation
    - Ensures all navigation operations are thread-safe for UI
    - Aligns with iOS 18+ SwiftUI View protocol being @MainActor
    - Prevents actor isolation violations at compile time
    
 2. Research Evidence:
    - Apple WWDC 2024: "SwiftUI Views and their supporting objects should be MainActor isolated"
    - Swift Forums consensus: UI state management protocols should match implementation isolation
    - iOS 17+ best practice: Use @MainActor for navigation and UI state management
    
 3. Benefits:
    - Compile-time safety for navigation state changes
    - No runtime actor switching overhead for UI operations
    - Clear isolation boundaries for team development
    - Future-proof for Swift 6 strict concurrency
    
 4. Alternative Considered but Rejected:
    - nonisolated protocol methods: Unsafe for UI state changes
    - MainActor.assumeIsolated: Adds complexity and potential crashes
    - Non-isolated protocol: Creates actor isolation violations
 */
