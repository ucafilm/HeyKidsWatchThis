// NavigationManager.swift - FINAL FIXED VERSION WITH PROPER BINDING SUPPORT
// Following TDD + RAG + Context7 methodology

import SwiftUI
import Observation

/// Main navigation manager for the app
/// Handles tab navigation and service dependencies
@MainActor
@Observable
final class NavigationManager: NavigationManagerProtocol {
    
    // MARK: - Published Properties
    
    var selectedTab: AppTab = .movies
    
    // MARK: - Services
    
    let movieService: MovieServiceProtocol
    let memoryService: MemoryServiceProtocol
    
    // MARK: - Initialization
    
    init(movieService: MovieServiceProtocol, memoryService: MemoryServiceProtocol) {
        self.movieService = movieService
        self.memoryService = memoryService
    }
    
    // MARK: - Convenience Initializer
    
    convenience init() {
        // Create default service implementations
        let movieDataProvider = MovieDataProvider()
        let memoryDataProvider = MemoryDataProvider()
        
        let movieService = MovieService(dataProvider: movieDataProvider)
        let memoryService = MemoryService(dataProvider: memoryDataProvider)
        
        self.init(movieService: movieService, memoryService: memoryService)
    }
    
    // MARK: - Navigation Methods
    
    func navigateToTab(_ tab: AppTab) {
        withAnimation(.smooth(duration: 0.3)) {
            selectedTab = tab
        }
    }
    
    func navigateToMovies() {
        navigateToTab(.movies)
    }
    
    func navigateToWatchlist() {
        navigateToTab(.watchlist)
    }
    
    func navigateToMemories() {
        navigateToTab(.memories)
    }
    
    func navigateToSettings() {
        navigateToTab(.settings)
    }
    
    // MARK: - Service Refresh Methods
    
    func refreshMovies() async {
        // Refresh movie data if needed
        // Implementation depends on your movie service
    }
    
    func refreshMemories() async {
        // Refresh memory data
        _ = memoryService.loadMemories()
    }
}

// MARK: - ObservableObject Conformance (Required for @EnvironmentObject)
extension NavigationManager: ObservableObject {
    // @Observable provides the objectWillChange publisher automatically
    // This extension satisfies the ObservableObject requirement for @EnvironmentObject
}
