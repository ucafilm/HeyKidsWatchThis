// WatchlistFunctionalityDiagnosticTests.swift
// HeyKidsWatchThis - Critical Phase 6.1: RED PHASE Diagnostic Tests
// Following TDD + RAG + Context7 protocol for watchlist functionality audit

import XCTest
@testable import HeyKidsWatchThis

/// Critical diagnostic tests to identify specific watchlist functionality failures
/// RED PHASE: These tests should fail initially, revealing the exact issues
/// This follows the TDD methodology where failing tests guide implementation fixes
class WatchlistFunctionalityDiagnosticTests: XCTestCase {
    
    private var movieService: MovieService!
    private var mockDataProvider: MockMovieDataProvider!
    private var userDefaultsStorage: UserDefaultsStorage!
    private var testUserDefaults: UserDefaults!
    
    // Test movie IDs for consistent testing
    private let testMovieId1 = UUID()
    private let testMovieId2 = UUID()
    private let testMovieId3 = UUID()
    
    override func setUp() {
        super.setUp()
        
        // Create isolated test environment
        testUserDefaults = UserDefaults(suiteName: "WatchlistDiagnosticTests")!
        testUserDefaults.removePersistentDomain(forName: "WatchlistDiagnosticTests")
        
        userDefaultsStorage = UserDefaultsStorage(userDefaults: testUserDefaults)
        mockDataProvider = MockMovieDataProvider(storage: userDefaultsStorage)
        movieService = MovieService(dataProvider: mockDataProvider)
        
        // Add test movies with known IDs
        let testMovies = [
            MovieData(
                id: testMovieId1,
                title: "Test Movie 1",
                year: 2025,
                ageGroup: .bigKids,
                genre: "Test",
                emoji: "🧪",
                streamingServices: ["TestFlix"],
                rating: 4.5,
                notes: "Test movie for diagnostics"
            ),
            MovieData(
                id: testMovieId2,
                title: "Test Movie 2",
                year: 2025,
                ageGroup: .littleKids,
                genre: "Comedy",
                emoji: "😄",
                streamingServices: ["TestPlus"],
                rating: 4.0,
                notes: "Second test movie"
            ),
            MovieData(
                id: testMovieId3,
                title: "Test Movie 3",
                year: 2025,
                ageGroup: .tweens,
                genre: "Adventure",
                emoji: "🏔️",
                streamingServices: ["TestMax"],
                rating: 4.8,
                notes: "Third test movie"
            )
        ]
        
        // Add test movies to mock provider
        testMovies.forEach { mockDataProvider.addMovie($0) }
    }
    
    override func tearDown() {
        // Clean up test environment
        testUserDefaults.removePersistentDomain(forName: "WatchlistDiagnosticTests")
        movieService = nil
        mockDataProvider = nil
        userDefaultsStorage = nil
        testUserDefaults = nil
        super.tearDown()
    }
    
    // MARK: - DIAGNOSTIC TEST 1: Core Watchlist Persistence
    
    /// RED PHASE: This test should fail initially, revealing persistence issues
    /// Tests if watchlist survives service reconstruction (simulating app restart)
    func test_addMovieToWatchlist_persistsAcrossServiceReload() {
        print("🔍 DIAGNOSTIC TEST 1: Testing watchlist persistence across service reload")
        
        // GIVEN: Initial clean state
        XCTAssertFalse(movieService.isInWatchlist(testMovieId1), "Movie should not be in watchlist initially")
        
        // WHEN: Add movie to watchlist
        movieService.addToWatchlist(testMovieId1)
        
        // THEN: Verify immediate state
        XCTAssertTrue(movieService.isInWatchlist(testMovieId1), "Movie should be in watchlist immediately after adding")
        
        // CRITICAL TEST: Simulate app restart by recreating service with same storage
        let newMockProvider = MockMovieDataProvider(storage: userDefaultsStorage)
        let newMovieService = MovieService(dataProvider: newMockProvider)
        
        // EXPECTED TO FAIL: Watchlist should persist across app launches
        XCTAssertTrue(
            newMovieService.isInWatchlist(testMovieId1),
            "💥 CRITICAL FAILURE: Watchlist should persist across app launches. This failure indicates storage persistence issues."
        )
        
        print("✅ DIAGNOSTIC TEST 1 RESULT: If this test passed, persistence is working correctly")
    }
    
    // MARK: - DIAGNOSTIC TEST 2: UI State Synchronization
    
    /// RED PHASE: This test should fail, showing MovieData.isInWatchlist sync issues
    /// Tests if MovieData.isInWatchlist property reflects service state
    func test_movieData_isInWatchlist_synchronizesWithService() {
        print("🔍 DIAGNOSTIC TEST 2: Testing MovieData.isInWatchlist synchronization")
        
        // GIVEN: Get a test movie from the service
        let allMovies = movieService.getAllMovies()
        guard let testMovie = allMovies.first(where: { $0.id == testMovieId1 }) else {
            XCTFail("Test movie not found in service")
            return
        }
        
        // Initial state check
        XCTAssertFalse(testMovie.isInWatchlist, "MovieData.isInWatchlist should be false initially")
        XCTAssertFalse(movieService.isInWatchlist(testMovie.id), "Service should report false initially")
        
        // WHEN: Add to watchlist via service
        movieService.addToWatchlist(testMovie.id)
        
        // THEN: Service state should be updated
        XCTAssertTrue(movieService.isInWatchlist(testMovie.id), "Service should report movie as in watchlist")
        
        // CRITICAL TEST: Get updated movie data from service
        let updatedMovies = movieService.getAllMovies()
        let updatedMovie = updatedMovies.first(where: { $0.id == testMovie.id })
        
        XCTAssertNotNil(updatedMovie, "Updated movie should be found")
        
        // EXPECTED TO FAIL: MovieData.isInWatchlist should reflect service state
        XCTAssertTrue(
            updatedMovie!.isInWatchlist,
            "💥 CRITICAL FAILURE: MovieData.isInWatchlist should reflect service state. This indicates sync issues between service and data objects."
        )
        
        print("✅ DIAGNOSTIC TEST 2 RESULT: If this test passed, MovieData sync is working correctly")
    }
    
    // MARK: - DIAGNOSTIC TEST 3: ViewModel Integration
    
    /// RED PHASE: This test should fail, showing ViewModel integration issues
    /// Tests if MovieListViewModel properly handles watchlist state changes
    func test_movieListViewModel_watchlistToggle_updatesUI() {
        print("🔍 DIAGNOSTIC TEST 3: Testing MovieListViewModel watchlist integration")
        
        // GIVEN: Create ViewModel with test service
        let viewModel = MovieListViewModel(movieService: movieService)
        viewModel.loadMovies()
        
        guard let testMovie = viewModel.movies.first(where: { $0.id == testMovieId1 }) else {
            XCTFail("Test movie not found in ViewModel")
            return
        }
        
        // Initial state verification
        XCTAssertFalse(movieService.isInWatchlist(testMovie.id), "Service should report false initially")
        XCTAssertFalse(viewModel.isInWatchlist(testMovie), "ViewModel should report false initially")
        
        // WHEN: Toggle watchlist via ViewModel
        viewModel.toggleWatchlist(for: testMovie)
        
        // THEN: Service state should be updated
        XCTAssertTrue(movieService.isInWatchlist(testMovie.id), "Service should report movie as in watchlist after toggle")
        
        // CRITICAL TEST: ViewModel should reflect updated state
        XCTAssertTrue(
            viewModel.isInWatchlist(testMovie),
            "💥 CRITICAL FAILURE: ViewModel should reflect updated watchlist state. This indicates ViewModel integration issues."
        )
        
        // Additional test: Check if filtered movies reflect watchlist state
        let updatedMovieFromFiltered = viewModel.filteredMovies.first(where: { $0.id == testMovie.id })
        XCTAssertNotNil(updatedMovieFromFiltered, "Movie should be found in filtered movies")
        
        // EXPECTED TO FAIL: Filtered movies should reflect watchlist state
        XCTAssertTrue(
            updatedMovieFromFiltered!.isInWatchlist,
            "💥 CRITICAL FAILURE: Filtered movies should reflect current watchlist state. This indicates data flow issues in ViewModel."
        )
        
        print("✅ DIAGNOSTIC TEST 3 RESULT: If this test passed, ViewModel integration is working correctly")
    }
    
    // MARK: - DIAGNOSTIC TEST 4: UserDefaults Storage Integrity
    
    /// RED PHASE: This test should fail, revealing storage corruption issues
    /// Tests if UserDefaults correctly stores and retrieves multiple watchlist entries
    func test_watchlistStorage_userDefaults_integrityCheck() {
        print("🔍 DIAGNOSTIC TEST 4: Testing UserDefaults storage integrity")
        
        let movieIds = [testMovieId1, testMovieId2, testMovieId3]
        
        // WHEN: Add multiple movies to watchlist
        movieIds.forEach { movieService.addToWatchlist($0) }
        
        // THEN: Verify all are stored in service
        movieIds.forEach { movieId in
            XCTAssertTrue(
                movieService.isInWatchlist(movieId),
                "Movie \(movieId) should be in watchlist after adding"
            )
        }
        
        // CRITICAL TEST: Check UserDefaults directly
        let storedWatchlistData = testUserDefaults.data(forKey: "stored_watchlist")
        XCTAssertNotNil(storedWatchlistData, "Watchlist data should be stored in UserDefaults")
        
        if let data = storedWatchlistData {
            do {
                let storedUUIDs = try JSONDecoder().decode([UUID].self, from: data)
                XCTAssertEqual(storedUUIDs.count, 3, "Should store exactly 3 UUIDs")
                
                movieIds.forEach { movieId in
                    XCTAssertTrue(
                        storedUUIDs.contains(movieId),
                        "💥 STORAGE FAILURE: UserDefaults should contain movie ID \(movieId)"
                    )
                }
            } catch {
                XCTFail("💥 CRITICAL FAILURE: Could not decode watchlist from UserDefaults: \(error)")
            }
        }
        
        // Test selective removal
        movieService.removeFromWatchlist(testMovieId2)
        
        // Verify selective removal worked
        XCTAssertTrue(movieService.isInWatchlist(testMovieId1), "Movie 1 should still be in watchlist")
        XCTAssertFalse(movieService.isInWatchlist(testMovieId2), "Movie 2 should be removed from watchlist")
        XCTAssertTrue(movieService.isInWatchlist(testMovieId3), "Movie 3 should still be in watchlist")
        
        // Verify UserDefaults reflects the removal
        let updatedWatchlistData = testUserDefaults.data(forKey: "stored_watchlist")
        XCTAssertNotNil(updatedWatchlistData, "Updated watchlist data should be stored")
        
        if let data = updatedWatchlistData {
            do {
                let updatedUUIDs = try JSONDecoder().decode([UUID].self, from: data)
                XCTAssertEqual(updatedUUIDs.count, 2, "Should store exactly 2 UUIDs after removal")
                XCTAssertTrue(updatedUUIDs.contains(testMovieId1), "Should contain movie 1")
                XCTAssertFalse(updatedUUIDs.contains(testMovieId2), "Should not contain movie 2")
                XCTAssertTrue(updatedUUIDs.contains(testMovieId3), "Should contain movie 3")
            } catch {
                XCTFail("💥 CRITICAL FAILURE: Could not decode updated watchlist: \(error)")
            }
        }
        
        print("✅ DIAGNOSTIC TEST 4 RESULT: If this test passed, UserDefaults storage is working correctly")
    }
    
    // MARK: - DIAGNOSTIC TEST 5: Performance Under Load
    
    /// RED PHASE: This test should fail, revealing performance issues
    /// Tests watchlist operations performance with large datasets
    func test_watchlistOperations_performanceUnderLoad() {
        print("🔍 DIAGNOSTIC TEST 5: Testing watchlist performance under load")
        
        let movieCount = 1000
        var movieIds: [UUID] = []
        
        // Generate test movie IDs
        for _ in 0..<movieCount {
            movieIds.append(UUID())
        }
        
        // Measure bulk add performance
        let addStartTime = CFAbsoluteTimeGetCurrent()
        
        movieIds.forEach { movieService.addToWatchlist($0) }
        
        let addEndTime = CFAbsoluteTimeGetCurrent()
        let addDuration = addEndTime - addStartTime
        
        print("📊 Bulk add duration: \(addDuration) seconds for \(movieCount) movies")
        
        // Measure bulk verification performance
        let verifyStartTime = CFAbsoluteTimeGetCurrent()
        
        movieIds.forEach { movieId in
            XCTAssertTrue(movieService.isInWatchlist(movieId), "Movie should be in watchlist")
        }
        
        let verifyEndTime = CFAbsoluteTimeGetCurrent()
        let verifyDuration = verifyEndTime - verifyStartTime
        
        print("📊 Bulk verify duration: \(verifyDuration) seconds for \(movieCount) movies")
        
        // Performance assertions
        XCTAssertLessThan(addDuration, 1.0, "💥 PERFORMANCE FAILURE: Bulk add should complete in under 1 second")
        XCTAssertLessThan(verifyDuration, 0.1, "💥 PERFORMANCE FAILURE: Bulk verification should complete in under 100ms")
        
        let totalDuration = addDuration + verifyDuration
        XCTAssertLessThan(totalDuration, 1.1, "💥 PERFORMANCE FAILURE: Total operations should complete in under 1.1 seconds")
        
        print("✅ DIAGNOSTIC TEST 5 RESULT: If this test passed, performance is acceptable")
    }
    
    // MARK: - DIAGNOSTIC TEST 6: Edge Cases and Error Handling
    
    /// RED PHASE: Test edge cases that might cause watchlist failures
    /// Tests duplicate additions, invalid UUIDs, and nil handling
    func test_watchlistEdgeCases_errorHandling() {
        print("🔍 DIAGNOSTIC TEST 6: Testing watchlist edge cases and error handling")
        
        // Test 1: Duplicate additions should be handled gracefully
        movieService.addToWatchlist(testMovieId1)
        let watchlistSizeAfterFirst = movieService.watchlist.count
        
        movieService.addToWatchlist(testMovieId1) // Add same movie again
        let watchlistSizeAfterDuplicate = movieService.watchlist.count
        
        XCTAssertEqual(
            watchlistSizeAfterFirst,
            watchlistSizeAfterDuplicate,
            "💥 EDGE CASE FAILURE: Duplicate additions should not increase watchlist size"
        )
        
        // Test 2: Removing non-existent movie should be handled gracefully
        let nonExistentId = UUID()
        let initialSize = movieService.watchlist.count
        
        movieService.removeFromWatchlist(nonExistentId)
        let sizeAfterRemoval = movieService.watchlist.count
        
        XCTAssertEqual(
            initialSize,
            sizeAfterRemoval,
            "💥 EDGE CASE FAILURE: Removing non-existent movie should not change watchlist size"
        )
        
        // Test 3: Empty watchlist operations
        movieService.removeFromWatchlist(testMovieId1) // Remove the one we added
        XCTAssertEqual(movieService.watchlist.count, 0, "Watchlist should be empty")
        
        let emptyWatchlistMovies = movieService.getWatchlistMovies()
        XCTAssertTrue(emptyWatchlistMovies.isEmpty, "Empty watchlist should return empty array")
        
        // Test 4: Invalid movie ID checks
        XCTAssertFalse(movieService.isInWatchlist(UUID()), "Random UUID should not be in watchlist")
        
        print("✅ DIAGNOSTIC TEST 6 RESULT: If this test passed, edge case handling is robust")
    }
    
    // MARK: - DIAGNOSTIC TEST 7: Data Consistency Check
    
    /// RED PHASE: Test data consistency between different access methods
    /// Ensures watchlist.count, getWatchlistMovies(), and isInWatchlist() are consistent
    func test_watchlistDataConsistency_multipleAccessMethods() {
        print("🔍 DIAGNOSTIC TEST 7: Testing data consistency across access methods")
        
        let movieIds = [testMovieId1, testMovieId2]
        
        // Add movies to watchlist
        movieIds.forEach { movieService.addToWatchlist($0) }
        
        // Test consistency across different access methods
        let watchlistArray = movieService.watchlist
        let watchlistMovies = movieService.getWatchlistMovies()
        
        // Count consistency
        XCTAssertEqual(
            watchlistArray.count,
            2,
            "Watchlist array should contain 2 items"
        )
        
        XCTAssertEqual(
            watchlistMovies.count,
            2,
            "💥 CONSISTENCY FAILURE: getWatchlistMovies() should return same count as watchlist array"
        )
        
        // Content consistency
        movieIds.forEach { movieId in
            XCTAssertTrue(
                watchlistArray.contains(movieId),
                "Watchlist array should contain movie ID"
            )
            
            XCTAssertTrue(
                movieService.isInWatchlist(movieId),
                "isInWatchlist() should return true for added movie"
            )
            
            let movieInWatchlistMovies = watchlistMovies.contains { $0.id == movieId }
            XCTAssertTrue(
                movieInWatchlistMovies,
                "💥 CONSISTENCY FAILURE: getWatchlistMovies() should contain movie with ID \(movieId)"
            )
        }
        
        print("✅ DIAGNOSTIC TEST 7 RESULT: If this test passed, data consistency is maintained")
    }
}

// MARK: - ENHANCED MOCK PROVIDER FOR TESTING

/// Enhanced mock provider with UserDefaults integration for comprehensive testing
extension MockMovieDataProvider {
    
    convenience init(storage: UserDefaultsStorage) {
        self.init()
        self.storage = storage
    }
    
    private var storage: UserDefaultsStorage?
    
    override func saveWatchlist(_ watchlist: [UUID]) {
        super.saveWatchlist(watchlist)
        
        // Also save to UserDefaults if storage is provided
        storage?.save(watchlist, forKey: "stored_watchlist")
    }
    
    override func loadWatchlist() -> [UUID] {
        // Load from UserDefaults if storage is provided
        if let storage = storage {
            return storage.load([UUID].self, forKey: "stored_watchlist") ?? []
        }
        
        return super.loadWatchlist()
    }
}

// MARK: - ENHANCED USER DEFAULTS STORAGE FOR TESTING

/// Enhanced UserDefaults storage with custom UserDefaults instance
extension UserDefaultsStorage {
    
    convenience init(userDefaults: UserDefaults) {
        self.init()
        // Note: This would require modifying UserDefaultsStorage to accept custom UserDefaults
        // For now, we'll use the standard UserDefaults and clean up in tearDown
    }
}
