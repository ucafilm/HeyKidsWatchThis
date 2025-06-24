// MovieListViewModelTests.swift
// HeyKidsWatchThis - MovieListViewModel Tests following established TDD pattern

import XCTest
@testable import HeyKidsWatchThis

class MovieListViewModelTests: XCTestCase {
    
    var viewModel: MovieListViewModel!
    var mockDataProvider: MockMovieDataProvider!
    var movieService: MovieService!
    
    override func setUp() {
        super.setUp()
        mockDataProvider = MockMovieDataProvider()
        movieService = MovieService(dataProvider: mockDataProvider)
        viewModel = MovieListViewModel(movieService: movieService)
    }
    
    override func tearDown() {
        viewModel = nil
        movieService = nil
        mockDataProvider = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testViewModelInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.movies.count, 0, "Movies should be empty initially")
        XCTAssertEqual(viewModel.searchText, "", "Search text should be empty initially")
        XCTAssertNil(viewModel.selectedAgeGroup, "Selected age group should be nil initially")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false initially")
    }
    
    // MARK: - Load Movies Tests
    
    func testLoadMoviesWithSampleData() {
        // When
        viewModel.loadMovies()
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
        XCTAssertGreaterThan(viewModel.movies.count, 0, "Should load sample movies")
        
        // Verify sample data is loaded
        let movieTitles = viewModel.movies.map { $0.title }
        XCTAssertTrue(movieTitles.contains("My Neighbor Totoro"), "Should contain sample movie")
    }
    
    func testLoadMoviesUpdatesLoadingState() {
        // When
        viewModel.loadMovies()
        
        // Then - loading state should be properly managed
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
    }
    
    // MARK: - Watchlist Tests
    
    func testToggleWatchlistAddsMovie() {
        // Given
        viewModel.loadMovies()
        let testMovie = viewModel.movies.first!
        
        // When
        viewModel.toggleWatchlist(for: testMovie)
        
        // Then
        XCTAssertTrue(viewModel.isInWatchlist(testMovie), "Movie should be added to watchlist")
    }
    
    func testToggleWatchlistRemovesMovie() {
        // Given
        viewModel.loadMovies()
        let testMovie = viewModel.movies.first!
        viewModel.toggleWatchlist(for: testMovie) // Add first
        
        // When
        viewModel.toggleWatchlist(for: testMovie) // Remove
        
        // Then
        XCTAssertFalse(viewModel.isInWatchlist(testMovie), "Movie should be removed from watchlist")
    }
    
    func testIsInWatchlistInitiallyFalse() {
        // Given
        viewModel.loadMovies()
        let testMovie = viewModel.movies.first!
        
        // Then
        XCTAssertFalse(viewModel.isInWatchlist(testMovie), "Movie should not be in watchlist initially")
    }
    
    // MARK: - Watched Movies Tests
    
    func testMarkAsWatched() {
        // Given
        viewModel.loadMovies()
        let testMovie = viewModel.movies.first!
        
        // When
        viewModel.markAsWatched(testMovie)
        
        // Then
        XCTAssertTrue(viewModel.isWatched(testMovie), "Movie should be marked as watched")
    }
    
    func testIsWatchedInitiallyFalse() {
        // Given
        viewModel.loadMovies()
        let testMovie = viewModel.movies.first!
        
        // Then
        XCTAssertFalse(viewModel.isWatched(testMovie), "Movie should not be watched initially")
    }
    
    // MARK: - Integration Tests
    
    func testViewModelIntegratesWithMockService() {
        // Given - Add some mock data
        let mockMovie = MovieData(
            id: UUID(),
            title: "Test Movie",
            year: 2025,
            ageGroup: .bigKids,
            genre: "Test",
            emoji: "🧪",
            streamingServices: ["TestFlix"]
        )
        mockDataProvider.movies = [mockMovie]
        
        // Create new viewModel with updated mock data
        let newMovieService = MovieService(dataProvider: mockDataProvider)
        let newViewModel = MovieListViewModel(movieService: newMovieService)
        
        // When
        newViewModel.loadMovies()
        
        // Then
        XCTAssertEqual(newViewModel.movies.count, 1, "Should load mock movie")
        XCTAssertEqual(newViewModel.movies.first?.title, "Test Movie", "Should load correct mock movie")
    }
    
    // MARK: - Performance Tests
    
    func testLoadMoviesPerformance() {
        measure {
            viewModel.loadMovies()
        }
    }
}
