// MovieSchedulingTDDTests.swift
// TDD tests for movie scheduling functionality
// Following RED-GREEN-REFACTOR methodology

import XCTest
@testable import HeyKidsWatchThis

@MainActor
final class MovieSchedulingTDDTests: XCTestCase {
    
    // MARK: - System Under Test
    private var sut: MovieService!
    private var mockDataProvider: MockMovieDataProvider!
    
    // Test data
    private var testMovie: MovieData!
    private var futureDate: Date!
    
    override func setUp() {
        super.setUp()
        
        // Create mock data provider
        mockDataProvider = MockMovieDataProvider()
        
        // Create system under test
        sut = MovieService(dataProvider: mockDataProvider)
        
        // Create test movie
        testMovie = MovieData(
            title: "Test Movie",
            year: 2024,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🎬",
            streamingServices: ["Netflix"]
        )
        
        // Create future date for scheduling
        futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // Add test movie to mock provider
        mockDataProvider.movies = [testMovie]
    }
    
    override func tearDown() {
        sut = nil
        mockDataProvider = nil
        testMovie = nil
        futureDate = nil
        super.tearDown()
    }
    
    // MARK: - TDD Tests: RED Phase (Failing Tests)
    
    func testScheduleMovie_withValidMovieId_shouldUpdateMovieScheduledDate() {
        // Given
        XCTAssertNil(testMovie.scheduledDate, "Movie should not be scheduled initially")
        
        // When
        sut.scheduleMovie(testMovie.id, for: futureDate)
        
        // Then
        let updatedMovie = sut.getMovie(by: testMovie.id)
        XCTAssertNotNil(updatedMovie?.scheduledDate, "Movie should have scheduled date after scheduling")
        XCTAssertEqual(updatedMovie?.scheduledDate, futureDate, "Scheduled date should match provided date")
    }
    
    func testScheduleMovie_withInvalidMovieId_shouldNotCrash() {
        // Given
        let invalidMovieId = UUID()
        
        // When & Then (should not crash)
        XCTAssertNoThrow(sut.scheduleMovie(invalidMovieId, for: futureDate))
    }
    
    func testScheduleMovie_withPastDate_shouldStillSchedule() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        // When
        sut.scheduleMovie(testMovie.id, for: pastDate)
        
        // Then
        let updatedMovie = sut.getMovie(by: testMovie.id)
        XCTAssertEqual(updatedMovie?.scheduledDate, pastDate, "Should allow scheduling for past dates (user choice)")
    }
    
    func testGetScheduledMovies_withScheduledMovie_shouldReturnCorrectMovies() {
        // Given
        sut.scheduleMovie(testMovie.id, for: futureDate)
        
        // When
        let scheduledMovies = sut.getScheduledMovies()
        
        // Then
        XCTAssertEqual(scheduledMovies.count, 1, "Should return one scheduled movie")
        XCTAssertEqual(scheduledMovies.first?.id, testMovie.id, "Should return the correct scheduled movie")
    }
    
    func testGetScheduledMovies_withNoScheduledMovies_shouldReturnEmptyArray() {
        // Given (no movies scheduled)
        
        // When
        let scheduledMovies = sut.getScheduledMovies()
        
        // Then
        XCTAssertTrue(scheduledMovies.isEmpty, "Should return empty array when no movies are scheduled")
    }
    
    func testRescheduleMovie_shouldUpdateExistingSchedule() {
        // Given
        let firstDate = futureDate!
        let secondDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        
        sut.scheduleMovie(testMovie.id, for: firstDate)
        
        // When
        sut.scheduleMovie(testMovie.id, for: secondDate)
        
        // Then
        let updatedMovie = sut.getMovie(by: testMovie.id)
        XCTAssertEqual(updatedMovie?.scheduledDate, secondDate, "Should update to the new scheduled date")
    }
    
    // MARK: - Integration Tests with MovieSchedulerView
    
    func testMovieSchedulerView_creation_shouldNotFail() {
        // Given
        let movieService = sut!
        
        // When & Then (should not crash or fail)
        XCTAssertNoThrow({
            let schedulerView = MovieSchedulerView(
                movie: testMovie,
                movieService: movieService,
                onDismiss: {}
            )
            
            // View should be created successfully
            XCTAssertNotNil(schedulerView)
        }())
    }
    
    // MARK: - Performance Tests
    
    func testScheduleMovie_performance() {
        // Given
        let movies = (0..<1000).map { index in
            MovieData(
                title: "Movie \(index)",
                year: 2024,
                ageGroup: .littleKids,
                genre: "Animation",
                emoji: "🎬",
                streamingServices: ["Netflix"]
            )
        }
        
        mockDataProvider.movies = movies
        
        // When & Then
        measure {
            for movie in movies.prefix(100) {
                sut.scheduleMovie(movie.id, for: futureDate)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testScheduleMovie_withSameDateMultipleTimes_shouldKeepLatestSchedule() {
        // Given
        let scheduleDate = futureDate!
        
        // When
        sut.scheduleMovie(testMovie.id, for: scheduleDate)
        sut.scheduleMovie(testMovie.id, for: scheduleDate)
        sut.scheduleMovie(testMovie.id, for: scheduleDate)
        
        // Then
        let scheduledMovies = sut.getScheduledMovies()
        XCTAssertEqual(scheduledMovies.count, 1, "Should only have one instance of the scheduled movie")
    }
    
    func testScheduleMovie_withExtremeFutureDate_shouldWork() {
        // Given
        let extremeFutureDate = Calendar.current.date(byAdding: .year, value: 100, to: Date())!
        
        // When
        sut.scheduleMovie(testMovie.id, for: extremeFutureDate)
        
        // Then
        let updatedMovie = sut.getMovie(by: testMovie.id)
        XCTAssertEqual(updatedMovie?.scheduledDate, extremeFutureDate, "Should handle extreme future dates")
    }
}

// MARK: - Mock Extensions for Testing

extension MockMovieDataProvider {
    func addTestMovies(count: Int = 5) {
        let testMovies = (0..<count).map { index in
            MovieData(
                title: "Test Movie \(index)",
                year: 2024,
                ageGroup: .littleKids,
                genre: "Animation",
                emoji: "🎬",
                streamingServices: ["Netflix"]
            )
        }
        self.movies = testMovies
    }
}

/*
 TDD METHODOLOGY APPLIED:

 🔴 RED PHASE: Written failing tests first
 - testScheduleMovie_withValidMovieId_shouldUpdateMovieScheduledDate
 - testGetScheduledMovies_withScheduledMovie_shouldReturnCorrectMovies
 - testRescheduleMovie_shouldUpdateExistingSchedule

 🟢 GREEN PHASE: Implement minimal code to pass tests
 - Add scheduleMovie method to MovieService
 - Add getScheduledMovies method to MovieService
 - Update MovieData to track scheduledDate

 🔵 REFACTOR PHASE: Improve code quality
 - Add error handling
 - Optimize performance
 - Add edge case handling
 - Improve user experience

 EXPECTED BENEFITS:
 - Reliable scheduling functionality
 - No duplicate MovieSchedulerView errors
 - Comprehensive test coverage
 - Performance validation
 - Edge case protection
*/
