// CompilationFixValidationTests.swift
// HeyKidsWatchThis - Tests to validate compilation error fixes
// Validates that the three missing methods are now properly implemented

import XCTest
@testable import HeyKidsWatchThis

class CompilationFixValidationTests: XCTestCase {
    
    var movieService: MovieService!
    var mockDataProvider: MockMovieDataProvider!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataProvider = MockMovieDataProvider()
        movieService = MovieService(dataProvider: mockDataProvider)
    }
    
    override func tearDownWithError() throws {
        movieService = nil
        mockDataProvider = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Missing Method Implementations
    
    func testClearWatchlistMethodExists() {
        // This test ensures the clearWatchlist() method exists and compiles
        // Before the fix, this would cause compilation error: "Value of type 'MovieService' has no member 'clearWatchlist'"
        
        // Arrange: Add some movies to watchlist
        let movies = movieService.getAllMovies()
        if let firstMovie = movies.first {
            movieService.addToWatchlist(firstMovie.id)
        }
        
        XCTAssertTrue(movieService.watchlist.count > 0, "Watchlist should have items before clearing")
        
        // Act: Clear the watchlist (this method was missing before the fix)
        movieService.clearWatchlist()
        
        // Assert: Watchlist should be empty
        XCTAssertEqual(movieService.watchlist.count, 0, "Watchlist should be empty after clearing")
    }
    
    func testAddMultipleToWatchlistMethodExists() {
        // This test ensures the addMultipleToWatchlist(_:) method exists and compiles
        // Before the fix, this would cause compilation error: "Value of type 'MovieService' has no member 'addMultipleToWatchlist'"
        
        // Arrange: Get some movie IDs
        let movies = movieService.getAllMovies()
        let movieIds = Array(movies.prefix(3).map { $0.id })
        
        XCTAssertEqual(movieService.watchlist.count, 0, "Watchlist should start empty")
        
        // Act: Add multiple movies to watchlist (this method was missing before the fix)
        movieService.addMultipleToWatchlist(movieIds)
        
        // Assert: Movies should be in watchlist
        XCTAssertTrue(movieService.watchlist.count > 0, "Watchlist should have items after bulk add")
        
        // Verify all valid movie IDs were added
        for movieId in movieIds {
            if movies.contains(where: { $0.id == movieId }) {
                XCTAssertTrue(movieService.isInWatchlist(movieId), "Movie \(movieId) should be in watchlist")
            }
        }
    }
    
    func testGetWatchlistStatisticsMethodExists() {
        // This test ensures the getWatchlistStatistics() method exists and compiles
        // Before the fix, this would cause compilation error: "Value of type 'MovieService' has no member 'getWatchlistStatistics'"
        
        // Arrange: Add some movies to watchlist with different age groups
        let movies = movieService.getAllMovies()
        let preschoolMovie = movies.first { $0.ageGroup == .preschoolers }
        let littleKidsMovie = movies.first { $0.ageGroup == .littleKids }
        
        if let preschoolMovie = preschoolMovie {
            movieService.addToWatchlist(preschoolMovie.id)
        }
        if let littleKidsMovie = littleKidsMovie {
            movieService.addToWatchlist(littleKidsMovie.id)
        }
        
        // Act: Get watchlist statistics (this method was missing before the fix)
        let statistics = movieService.getWatchlistStatistics()
        
        // Assert: Statistics should be properly structured
        XCTAssertNotNil(statistics, "Statistics should not be nil")
        XCTAssertTrue(statistics.totalCount >= 0, "Total count should be non-negative")
        XCTAssertTrue(statistics.averageRating >= 0.0, "Average rating should be non-negative")
        XCTAssertTrue(statistics.totalWatchedFromWatchlist >= 0, "Watched count should be non-negative")
        XCTAssertNotNil(statistics.ageGroupBreakdown, "Age group breakdown should not be nil")
        
        // Verify completion percentage calculation
        let expectedPercentage = statistics.totalCount > 0 ? 
            Double(statistics.totalWatchedFromWatchlist) / Double(statistics.totalCount) * 100 : 0
        XCTAssertEqual(statistics.completionPercentage, expectedPercentage, accuracy: 0.01, 
                      "Completion percentage should be calculated correctly")
    }
    
    // MARK: - Integration Test with MovieListViewModel
    
    func testMovieListViewModelCanCallAllMethods() {
        // This test ensures MovieListViewModel can successfully call all three previously missing methods
        // This validates the end-to-end fix of the compilation errors
        
        // Arrange: Create MovieListViewModel with real MovieService
        let viewModel = MovieListViewModel(movieService: movieService)
        
        // Act & Assert: These method calls should now compile and execute without errors
        
        // 1. Test clearWatchlist() call from ViewModel
        XCTAssertNoThrow(viewModel.clearWatchlist(), "clearWatchlist should not throw")
        
        // 2. Test addToWatchlistBulk() which internally calls addMultipleToWatchlist()
        let movies = viewModel.movies.prefix(2)
        XCTAssertNoThrow(viewModel.addToWatchlistBulk(movies: Array(movies)), "Bulk add should not throw")
        
        // 3. Test getWatchlistStatistics() call from ViewModel
        let statistics = viewModel.getWatchlistStatistics()
        XCTAssertNotNil(statistics, "Statistics should be available from ViewModel")
    }
    
    // MARK: - Performance and Edge Case Tests
    
    func testBulkOperationsPerformance() {
        // Test that bulk operations perform well with larger datasets
        let movies = movieService.getAllMovies()
        let movieIds = movies.map { $0.id }
        
        // Measure performance of bulk add
        measure {
            movieService.addMultipleToWatchlist(movieIds)
            movieService.clearWatchlist()
        }
    }
    
    func testWatchlistStatisticsWithEmptyWatchlist() {
        // Test statistics calculation with empty watchlist
        movieService.clearWatchlist()
        
        let statistics = movieService.getWatchlistStatistics()
        
        XCTAssertEqual(statistics.totalCount, 0)
        XCTAssertEqual(statistics.averageRating, 0.0)
        XCTAssertEqual(statistics.totalWatchedFromWatchlist, 0)
        XCTAssertEqual(statistics.completionPercentage, 0.0)
        XCTAssertTrue(statistics.ageGroupBreakdown.isEmpty)
    }
    
    func testBulkAddWithInvalidMovieIds() {
        // Test bulk add with mix of valid and invalid movie IDs
        let validMovies = movieService.getAllMovies()
        let validId = validMovies.first?.id ?? UUID()
        let invalidId = UUID()
        
        let mixedIds = [validId, invalidId]
        
        movieService.addMultipleToWatchlist(mixedIds)
        
        // Only valid IDs should be added
        XCTAssertTrue(movieService.isInWatchlist(validId))
        XCTAssertFalse(movieService.isInWatchlist(invalidId))
    }
    
    // MARK: - Protocol Conformance Test
    
    func testMovieServiceConformsToProtocol() {
        // This test ensures MovieService still properly conforms to MovieServiceProtocol
        // after adding the new methods
        
        let service: MovieServiceProtocol = movieService
        
        // Test that all protocol methods are available through the protocol
        XCTAssertNoThrow(service.clearWatchlist())
        XCTAssertNoThrow(service.addMultipleToWatchlist([]))
        XCTAssertNoThrow(_ = service.getWatchlistStatistics())
        
        // Test other existing protocol methods still work
        XCTAssertNoThrow(_ = service.getAllMovies())
        XCTAssertNoThrow(_ = service.watchlist)
        XCTAssertNoThrow(service.addToWatchlist(UUID()))
    }
}

// MARK: - Build Success Verification

// This class serves as a compile-time check that all methods exist
class CompilationSuccessVerification {
    
    func verifyAllMethodsCompile() {
        // This method should compile successfully if all fixes are applied
        let mockDataProvider = MockMovieDataProvider()
        let movieService = MovieService(dataProvider: mockDataProvider)
        
        // These three lines would cause compilation errors before the fix:
        movieService.clearWatchlist()                    // ✅ FIXED
        movieService.addMultipleToWatchlist([])          // ✅ FIXED  
        let _ = movieService.getWatchlistStatistics()    // ✅ FIXED
        
        // Create ViewModel to verify integration
        let viewModel = MovieListViewModel(movieService: movieService)
        
        // These ViewModel calls should also work:
        viewModel.clearWatchlist()                       // ✅ FIXED
        viewModel.addToWatchlistBulk(movies: [])         // ✅ FIXED
        let _ = viewModel.getWatchlistStatistics()       // ✅ FIXED
        
        print("✅ All compilation fixes verified successfully!")
    }
}
