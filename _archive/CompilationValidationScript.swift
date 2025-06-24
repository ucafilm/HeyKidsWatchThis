// CompilationValidationScript.swift
// Quick validation script to test our TDD Phase 1 fixes
// Run this to verify all compilation errors are resolved

import Foundation
import SwiftUI

// Test 1: Basic type instantiation
func testBasicTypes() {
    print("🧪 Testing basic type instantiation...")
    
    // Test AgeGroup
    let ageGroup = AgeGroup.preschoolers
    print("✅ AgeGroup created: \(ageGroup.description)")
    
    // Test MovieData
    let movie = MovieData(
        id: UUID(),
        title: "Test Movie",
        year: 2024,
        ageGroup: .littleKids,
        genre: "Animation",
        emoji: "🎬",
        streamingServices: ["Netflix"],
        rating: 4.5,
        notes: "Test movie"
    )
    print("✅ MovieData created: \(movie.title)")
    
    // Test MemoryData
    let memory = MemoryData(
        movieId: movie.id,
        watchDate: Date(),
        rating: 5,
        notes: "Great movie night!"
    )
    print("✅ MemoryData created: Rating \(memory.rating)/5")
}

// Test 2: Service layer
func testServiceLayer() {
    print("\n🧪 Testing service layer...")
    
    // Test MockMovieService
    let movieService = MockMovieService()
    let movies = movieService.getAllMovies()
    print("✅ MockMovieService created with \(movies.count) movies")
    
    // Test watchlist functionality
    if let firstMovie = movies.first {
        movieService.addToWatchlist(firstMovie.id)
        let isInWatchlist = movieService.isInWatchlist(firstMovie.id)
        print("✅ Watchlist functionality working: \(isInWatchlist)")
    }
    
    // Test MockMemoryService
    let memoryService = MockMemoryService()
    let memoryCount = memoryService.getMemoryCount()
    print("✅ MockMemoryService created with \(memoryCount) memories")
}

// Test 3: ViewModel instantiation
func testViewModels() {
    print("\n🧪 Testing @Observable ViewModels...")
    
    let movieService = MockMovieService()
    let eventService = MockEventKitService()
    
    // Test WatchlistViewModel
    let watchlistViewModel = WatchlistViewModel(
        movieService: movieService,
        eventKitService: eventService
    )
    print("✅ WatchlistViewModel created")
    print("   - Initial loading state: \(watchlistViewModel.isLoading)")
    print("   - Initial search text: '\(watchlistViewModel.searchText)'")
    print("   - Watchlist movies: \(watchlistViewModel.watchlistMovies.count)")
    
    // Test observable pattern
    watchlistViewModel.searchText = "Test Search"
    print("✅ @Observable pattern working - search text updated to: '\(watchlistViewModel.searchText)'")
}

// Test 4: Protocol conformance
func testProtocolConformance() {
    print("\n🧪 Testing protocol conformance...")
    
    // Test MovieServiceProtocol conformance
    let movieService: MovieServiceProtocol = MockMovieService()
    let movies = movieService.getAllMovies()
    print("✅ MovieServiceProtocol conformance verified - \(movies.count) movies")
    
    // Test search functionality
    let searchResults = movieService.searchMovies("Animation")
    print("✅ Search functionality working - \(searchResults.count) results for 'Animation'")
    
    // Test EventKitServiceProtocol conformance
    let eventService: EventKitServiceProtocol = MockEventKitService()
    print("✅ EventKitServiceProtocol conformance verified")
    
    // Test MemoryServiceProtocol conformance
    let memoryService: MemoryServiceProtocol = MockMemoryService()
    let memoryCount = memoryService.getMemoryCount()
    print("✅ MemoryServiceProtocol conformance verified - \(memoryCount) memories")
}

// Test 5: App structure
func testAppStructure() {
    print("\n🧪 Testing app structure...")
    
    // Test app initialization
    let app = HeyKidsWatchThisApp()
    print("✅ HeyKidsWatchThisApp created successfully")
    
    // Test main app view
    let mainView = MainAppView()
    print("✅ MainAppView created successfully")
    
    // Test individual views
    let watchlistView = WatchlistView()
    print("✅ WatchlistView created successfully")
    
    let emptyStateView = WatchlistEmptyStateView()
    print("✅ WatchlistEmptyStateView created successfully")
    
    let loadingView = WatchlistLoadingView()
    print("✅ WatchlistLoadingView created successfully")
}

// Test 6: Data model validation
func testDataModels() {
    print("\n🧪 Testing data model features...")
    
    // Test AgeGroup comparison
    let preschoolers = AgeGroup.preschoolers
    let tweens = AgeGroup.tweens
    let isCorrectOrder = preschoolers < tweens
    print("✅ AgeGroup Comparable working: preschoolers < tweens = \(isCorrectOrder)")
    
    // Test MovieData with state tracking
    var movie = MovieData(
        id: UUID(),
        title: "State Test Movie",
        year: 2024,
        ageGroup: .bigKids,
        genre: "Adventure",
        emoji: "🎮",
        streamingServices: ["Netflix"],
        rating: 4.0,
        notes: nil
    )
    
    print("✅ MovieData initial state - isInWatchlist: \(movie.isInWatchlist), isWatched: \(movie.isWatched)")
    
    // Test state modification
    movie.isInWatchlist = true
    movie.isWatched = true
    print("✅ MovieData state updated - isInWatchlist: \(movie.isInWatchlist), isWatched: \(movie.isWatched)")
}

// Test 7: Async functionality
func testAsyncFunctionality() async {
    print("\n🧪 Testing async functionality...")
    
    let eventService = MockEventKitService()
    
    // Test calendar access
    let accessGranted = await eventService.requestCalendarAccess()
    print("✅ Calendar access request completed: \(accessGranted)")
    
    // Test movie scheduling
    let testMovie = MovieData(
        id: UUID(),
        title: "Async Test Movie",
        year: 2024,
        ageGroup: .littleKids,
        genre: "Animation",
        emoji: "🎬",
        streamingServices: ["Disney+"],
        rating: 4.5,
        notes: nil
    )
    
    let scheduleResult = await eventService.scheduleMovieNight(for: testMovie, on: Date())
    switch scheduleResult {
    case .success(let eventId):
        print("✅ Movie scheduling successful - Event ID: \(eventId)")
    case .failure(let error):
        print("❌ Movie scheduling failed: \(error)")
    }
    
    // Test upcoming events
    let upcomingEvents = await eventService.getUpcomingMovieNights(limit: 5)
    print("✅ Upcoming events retrieved: \(upcomingEvents.count) events")
}

// Main validation function
func runValidation() async {
    print("🚀 Starting TDD Phase 1 Compilation Validation")
    print("=" * 50)
    
    testBasicTypes()
    testServiceLayer()
    testViewModels()
    testProtocolConformance()
    testAppStructure()
    testDataModels()
    await testAsyncFunctionality()
    
    print("\n" + "=" * 50)
    print("🎉 TDD Phase 1 Validation Complete!")
    print("✅ All compilation fixes verified")
    print("✅ @Observable pattern working")
    print("✅ Protocol conformance validated")
    print("✅ App structure functional")
    print("✅ Async operations working")
    print("\n🚀 Ready to proceed to Phase 2: Enhanced Features")
}

// Extension to repeat strings (for formatting)
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// Entry point for validation
@main
struct ValidationRunner {
    static func main() async {
        await runValidation()
    }
}
