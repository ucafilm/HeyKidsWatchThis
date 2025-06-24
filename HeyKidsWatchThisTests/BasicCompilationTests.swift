// BasicCompilationTests.swift
// HeyKidsWatchThis - Phase 1: TDD Compilation Fix Tests
// RED phase: Write failing tests that verify compilation issues are resolved

import XCTest
import SwiftUI
@testable import HeyKidsWatchThis

class BasicCompilationTests: XCTestCase {
    
    // MARK: - App Launch Tests
    
    func testAppLaunches() {
        // RED: This test fails until app compiles without errors
        let app = HeyKidsWatchThisApp()
        XCTAssertNotNil(app, "App should be able to initialize")
    }
    
    func testMainAppViewExists() {
        // RED: Test that MainAppView can be created
        let mainView = MainAppView()
        XCTAssertNotNil(mainView, "MainAppView should be able to initialize")
    }
    
    // MARK: - Core Model Tests
    
    func testBasicModelsExist() {
        // RED: Test that all basic models compile and work
        let ageGroup = AgeGroup.preschoolers
        XCTAssertEqual(ageGroup.description, "🧸 Preschoolers (2-4)")
        
        let movie = MovieData(
            title: "Test Movie",
            year: 2024,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🎬",
            streamingServices: ["Netflix"]
        )
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.ageGroup, .littleKids)
        XCTAssertFalse(movie.isInWatchlist)
        XCTAssertFalse(movie.isWatched)
    }
    
    func testMemoryDataModel() {
        // RED: Test MemoryData model
        let movieId = UUID()
        let memory = MemoryData(
            movieId: movieId,
            rating: 5,
            notes: "Great family movie!"
        )
        
        XCTAssertEqual(memory.movieId, movieId)
        XCTAssertEqual(memory.rating, 5)
        XCTAssertEqual(memory.notes, "Great family movie!")
        XCTAssertTrue(memory.discussionAnswers.isEmpty)
    }
    
    // MARK: - Service Layer Tests
    
    func testMockMovieServiceExists() {
        // RED: Test that MockMovieService compiles and works
        let service = MockMovieService()
        XCTAssertNotNil(service, "MockMovieService should initialize")
        
        let movies = service.getAllMovies()
        XCTAssertFalse(movies.isEmpty, "MockMovieService should have sample movies")
        
        // Test watchlist functionality
        let firstMovie = movies.first!
        service.addToWatchlist(firstMovie.id)
        XCTAssertTrue(service.isInWatchlist(firstMovie.id), "Movie should be in watchlist")
        
        service.removeFromWatchlist(firstMovie.id)
        XCTAssertFalse(service.isInWatchlist(firstMovie.id), "Movie should be removed from watchlist")
    }
    
    func testMockEventKitServiceExists() async {
        // RED: Test that MockEventKitService compiles and works
        let service = MockEventKitService()
        XCTAssertNotNil(service, "MockEventKitService should initialize")
        
        let accessGranted = await service.requestCalendarAccess()
        XCTAssertTrue(accessGranted, "Mock service should grant calendar access")
        
        let testMovie = MovieData(
            title: "Test Movie",
            year: 2024,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🎬",
            streamingServices: ["Netflix"]
        )
        
        let result = await service.scheduleMovieNight(for: testMovie, on: Date())
        switch result {
        case .success(let eventId):
            XCTAssertFalse(eventId.isEmpty, "Event ID should not be empty")
        case .failure(let error):
            XCTFail("Mock service should succeed, but failed with: \(error)")
        }
    }
    
    // MARK: - ViewModel Tests
    
    func testWatchlistViewModelExists() {
        // RED: Test that WatchlistViewModel compiles with @Observable
        let movieService = MockMovieService()
        let eventService = MockEventKitService()
        
        let viewModel = WatchlistViewModel(
            movieService: movieService,
            eventKitService: eventService
        )
        
        XCTAssertNotNil(viewModel, "WatchlistViewModel should initialize")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")
        XCTAssertTrue(viewModel.watchlistMovies.isEmpty, "Should start with empty watchlist")
        XCTAssertTrue(viewModel.searchText.isEmpty, "Search text should be empty initially")
    }
    
    func testWatchlistViewModelObservablePattern() {
        // RED: Test @Observable pattern works correctly
        let movieService = MockMovieService()
        let eventService = MockEventKitService()
        
        let viewModel = WatchlistViewModel(
            movieService: movieService,
            eventKitService: eventService
        )
        
        // Test that we can modify observable properties
        viewModel.searchText = "Moana"
        XCTAssertEqual(viewModel.searchText, "Moana")
        
        viewModel.isLoading = true
        XCTAssertTrue(viewModel.isLoading)
        
        // Test computed properties
        XCTAssertNotNil(viewModel.filteredWatchlist)
        XCTAssertTrue(viewModel.filteredWatchlist.isEmpty) // Should be empty with no movies
    }
    
    // MARK: - View Compilation Tests
    
    func testWatchlistViewCompiles() {
        // RED: Test that WatchlistView can be instantiated
        let view = WatchlistView()
        XCTAssertNotNil(view, "WatchlistView should be able to initialize")
    }
    
    func testWatchlistEmptyStateViewCompiles() {
        // RED: Test that empty state view compiles
        let emptyView = WatchlistEmptyStateView()
        XCTAssertNotNil(emptyView, "WatchlistEmptyStateView should initialize")
    }
    
    func testWatchlistLoadingViewCompiles() {
        // RED: Test that loading view compiles
        let loadingView = WatchlistLoadingView()
        XCTAssertNotNil(loadingView, "WatchlistLoadingView should initialize")
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testMovieServiceProtocolConformance() {
        // RED: Test that MockMovieService conforms to protocol correctly
        let service: MovieServiceProtocol = MockMovieService()
        
        // Test all protocol methods are implemented
        let movies = service.getAllMovies()
        XCTAssertNotNil(movies)
        
        let preschoolerMovies = service.getMovies(for: .preschoolers)
        XCTAssertNotNil(preschoolerMovies)
        
        let searchResults = service.searchMovies("Animation")
        XCTAssertNotNil(searchResults)
        
        // Test watchlist methods
        let testId = UUID()
        service.addToWatchlist(testId)
        XCTAssertTrue(service.isInWatchlist(testId))
        
        service.removeFromWatchlist(testId)
        XCTAssertFalse(service.isInWatchlist(testId))
        
        // Test watched tracking
        service.markAsWatched(testId)
        XCTAssertTrue(service.isWatched(testId))
    }
    
    func testEventKitServiceProtocolConformance() async {
        // RED: Test that MockEventKitService conforms to protocol correctly
        let service: EventKitServiceProtocol = MockEventKitService()
        
        // Test calendar access
        let accessGranted = await service.requestCalendarAccess()
        XCTAssertNotNil(accessGranted)
        
        // Test movie scheduling
        let testMovie = MovieData(
            title: "Protocol Test Movie",
            year: 2024,
            ageGroup: .bigKids,
            genre: "Adventure",
            emoji: "🎮",
            streamingServices: ["Netflix"]
        )
        
        let scheduleResult = await service.scheduleMovieNight(for: testMovie, on: Date())
        XCTAssertNotNil(scheduleResult)
        
        // Test time slot suggestions
        let timeSlots = service.findOptimalTimeSlots(
            for: testMovie,
            on: Date(),
            familyAgeGroups: [.bigKids, .tweens]
        )
        XCTAssertNotNil(timeSlots)
        
        // Test recurring events
        let recurringResult = await service.createRecurringMovieNight(
            movie: testMovie,
            pattern: .weekly,
            startDate: Date()
        )
        XCTAssertNotNil(recurringResult)
        
        // Test calendar management
        let calendars = await service.getFamilyCalendars()
        XCTAssertNotNil(calendars)
        
        // Test upcoming events
        let upcomingEvents = await service.getUpcomingMovieNights(limit: 5)
        XCTAssertNotNil(upcomingEvents)
    }
    
    // MARK: - Data Model Codable Tests
    
    func testMovieDataCodable() throws {
        // RED: Test that MovieData can be encoded/decoded properly
        let originalMovie = MovieData(
            title: "Codable Test Movie",
            year: 2024,
            ageGroup: .tweens,
            genre: "Sci-Fi",
            emoji: "🚀",
            streamingServices: ["Disney+", "Netflix"],
            rating: 4.5,
            notes: "Great for the whole family"
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalMovie)
        XCTAssertFalse(data.isEmpty, "Encoded data should not be empty")
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedMovie = try decoder.decode(MovieData.self, from: data)
        
        XCTAssertEqual(originalMovie.id, decodedMovie.id)
        XCTAssertEqual(originalMovie.title, decodedMovie.title)
        XCTAssertEqual(originalMovie.year, decodedMovie.year)
        XCTAssertEqual(originalMovie.ageGroup, decodedMovie.ageGroup)
        XCTAssertEqual(originalMovie.genre, decodedMovie.genre)
        XCTAssertEqual(originalMovie.emoji, decodedMovie.emoji)
        XCTAssertEqual(originalMovie.streamingServices, decodedMovie.streamingServices)
        XCTAssertEqual(originalMovie.rating, decodedMovie.rating)
        XCTAssertEqual(originalMovie.notes, decodedMovie.notes)
    }
    
    func testMemoryDataCodable() throws {
        // RED: Test that MemoryData can be encoded/decoded properly
        let discussionAnswer = DiscussionAnswer(
            questionId: UUID(),
            response: "I loved the characters!",
            childAge: 8
        )
        
        let originalMemory = MemoryData(
            movieId: UUID(),
            rating: 4,
            notes: "Amazing family night!",
            discussionAnswers: [discussionAnswer]
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalMemory)
        XCTAssertFalse(data.isEmpty, "Encoded data should not be empty")
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedMemory = try decoder.decode(MemoryData.self, from: data)
        
        XCTAssertEqual(originalMemory.id, decodedMemory.id)
        XCTAssertEqual(originalMemory.movieId, decodedMemory.movieId)
        XCTAssertEqual(originalMemory.rating, decodedMemory.rating)
        XCTAssertEqual(originalMemory.notes, decodedMemory.notes)
        XCTAssertEqual(originalMemory.discussionAnswers.count, decodedMemory.discussionAnswers.count)
        XCTAssertEqual(originalMemory.discussionAnswers.first?.response, decodedMemory.discussionAnswers.first?.response)
    }
    
    // MARK: - AgeGroup Tests
    
    func testAgeGroupComparable() {
        // RED: Test that AgeGroup comparison works correctly
        XCTAssertLessThan(AgeGroup.preschoolers, AgeGroup.littleKids)
        XCTAssertLessThan(AgeGroup.littleKids, AgeGroup.bigKids)
        XCTAssertLessThan(AgeGroup.bigKids, AgeGroup.tweens)
        
        XCTAssertGreaterThan(AgeGroup.tweens, AgeGroup.preschoolers)
    }
    
    func testAgeGroupDescriptions() {
        // RED: Test that AgeGroup descriptions are correct
        XCTAssertEqual(AgeGroup.preschoolers.description, "🧸 Preschoolers (2-4)")
        XCTAssertEqual(AgeGroup.littleKids.description, "🎨 Little Kids (5-7)")
        XCTAssertEqual(AgeGroup.bigKids.description, "🚀 Big Kids (8-9)")
        XCTAssertEqual(AgeGroup.tweens.description, "🎭 Tweens (10-12)")
    }
    
    // MARK: - Statistics Tests
    
    func testWatchlistStatistics() {
        // RED: Test WatchlistStatistics calculation
        let stats = WatchlistStatistics(
            totalCount: 10,
            averageRating: 4.5,
            completionPercentage: 70.0
        )
        
        XCTAssertEqual(stats.totalCount, 10)
        XCTAssertEqual(stats.averageRating, 4.5, accuracy: 0.01)
        XCTAssertEqual(stats.completionPercentage, 70.0, accuracy: 0.01)
    }
    
    // MARK: - Integration Tests
    
    func testWatchlistViewModelWithMockData() async {
        // RED: Test full integration of ViewModel with mock services
        let movieService = MockMovieService()
        let eventService = MockEventKitService()
        
        // Add some movies to watchlist
        let movies = movieService.getAllMovies()
        let firstThreeMovies = Array(movies.prefix(3))
        for movie in firstThreeMovies {
            movieService.addToWatchlist(movie.id)
        }
        
        let viewModel = WatchlistViewModel(
            movieService: movieService,
            eventKitService: eventService
        )
        
        // Load data
        await viewModel.loadWatchlistData()
        
        // Verify data loaded
        XCTAssertEqual(viewModel.watchlistMovies.count, 3, "Should have 3 movies in watchlist")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after data loads")
        
        // Test search functionality
        viewModel.searchText = "Moana"
        let filteredResults = viewModel.filteredWatchlist
        XCTAssertTrue(filteredResults.allSatisfy { $0.title.contains("Moana") }, "Filtered results should contain search term")
        
        // Test statistics
        let stats = viewModel.watchlistStatistics
        XCTAssertNotNil(stats, "Statistics should be available with movies in watchlist")
        XCTAssertEqual(stats?.totalCount, 3, "Total count should match watchlist size")
    }
    
    // MARK: - Performance Tests
    
    func testLargeMovieListPerformance() {
        // RED: Test that the app can handle large datasets efficiently
        self.measure {
            let service = MockMovieService()
            let movies = service.getAllMovies()
            
            // Simulate large dataset operations
            let _ = movies.filter { $0.ageGroup == .littleKids }
            let _ = movies.sorted { $0.title < $1.title }
            let _ = movies.compactMap { $0.rating }
        }
    }
    
    func testViewModelFilterPerformance() {
        // RED: Test ViewModel filtering performance
        let movieService = MockMovieService()
        let eventService = MockEventKitService()
        let viewModel = WatchlistViewModel(
            movieService: movieService,
            eventKitService: eventService
        )
        
        // Add all movies to watchlist for testing
        let allMovies = movieService.getAllMovies()
        for movie in allMovies {
            movieService.addToWatchlist(movie.id)
        }
        
        Task {
            await viewModel.loadWatchlistData()
        }
        
        self.measure {
            viewModel.searchText = "Animation"
            let _ = viewModel.filteredWatchlist
            
            viewModel.searchText = "Disney"
            let _ = viewModel.filteredWatchlist
            
            viewModel.searchText = ""
            let _ = viewModel.filteredWatchlist
        }
    }
}

// MARK: - Test Helper Extensions

extension XCTestCase {
    func waitForAsync<T>(
        timeout: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withTimeout(timeout) {
            try await operation()
        }
    }
    
    private func withTimeout<T>(
        _ timeout: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
}

struct TimeoutError: Error {}
