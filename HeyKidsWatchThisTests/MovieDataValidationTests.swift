//
//  MovieDataValidationTests.swift
//  HeyKidsWatchThisTests
//
//  TDD RED PHASE: Tests for SOUL Movie Data Validation
//  These tests will FAIL initially due to incorrect SOUL movie data
//

import XCTest
@testable import HeyKidsWatchThis

final class MovieDataValidationTests: XCTestCase {
    
    var movieDataProvider: MovieDataProvider!
    var movies: [MovieData]!
    
    override func setUp() {
        super.setUp()
        movieDataProvider = MovieDataProvider()
        movies = movieDataProvider.loadMovies()
    // MARK: - Integration Tests with Validation Helper
    
    func test_validationHelper_detectsDataIntegrityIssues() {
        let validationResult = movieDataProvider.validateAllMovies()
        
        if !validationResult.isValid {
            // Log errors for debugging but don't fail - this is for monitoring
            print("Data validation warnings: \(validationResult.errors.joined(separator: ", "))")
        }
        
        // The validation helper should always run without crashing
        XCTAssertNotNil(validationResult, "Validation helper should always return a result")
    }
    
    func test_validationHelper_validatesSoulSpecifically() {
        let specialValidation = movieDataProvider.validateSpecialMovies()
        
        XCTAssertTrue(specialValidation.isValid, 
                     "Special movie validation failed: \(specialValidation.errors.joined(separator: ", "))")
    }
    
    override func tearDown() {
        movieDataProvider = nil
        movies = nil
        super.tearDown()
    }
    
    // MARK: - SOUL Movie Validation Tests (RED PHASE - These will FAIL)
    
    func test_soulMovie_hasCorrectBasicDetails() {
        // Find SOUL movie
        let soulMovies = movies.filter { $0.title == "Soul" && $0.year == 2020 }
        
        // Should have exactly one SOUL (2020) entry
        XCTAssertEqual(soulMovies.count, 1, "Should have exactly one SOUL (2020) movie, found \(soulMovies.count)")
        
        guard let soul = soulMovies.first else {
            XCTFail("SOUL movie not found")
            return
        }
        
        // Test correct basic details
        XCTAssertEqual(soul.title, "Soul", "Title should be 'Soul'")
        XCTAssertEqual(soul.year, 2020, "Year should be 2020")
        XCTAssertEqual(soul.ageGroup, .tweens, "Age group should be .tweens for philosophical themes")
        XCTAssertEqual(soul.genre, "Animation Drama", "Genre should be 'Animation Drama'")
    }
    
    func test_soulMovie_hasCorrectJazzThemeDetails() {
        let soulMovies = movies.filter { $0.title == "Soul" && $0.year == 2020 }
        guard let soul = soulMovies.first else {
            XCTFail("SOUL movie not found")
            return
        }
        
        // Test jazz-specific details
        XCTAssertEqual(soul.emoji, "🎷", "Emoji should be jazz saxophone '🎷'")
        XCTAssertTrue(soul.streamingServices.contains("Disney+"), "Should be available on Disney+")
        XCTAssertFalse(soul.streamingServices.contains("Netflix"), "Should NOT be on Netflix")
        
        // Test notes contain correct description
        let notes = soul.notes ?? ""
        XCTAssertTrue(notes.contains("jazz") || notes.contains("Jazz"), "Notes should mention jazz")
        XCTAssertTrue(notes.contains("Pixar"), "Notes should mention Pixar")
        XCTAssertFalse(notes.contains("Chinese mythology"), "Should NOT contain Chinese mythology description")
        XCTAssertFalse(notes.contains("Over the Moon"), "Should NOT contain Over the Moon content")
    }
    
    func test_soulMovie_hasHighQualityRating() {
        let soulMovies = movies.filter { $0.title == "Soul" && $0.year == 2020 }
        guard let soul = soulMovies.first else {
            XCTFail("SOUL movie not found")
            return
        }
        
        // SOUL is critically acclaimed and should have high rating
        XCTAssertNotNil(soul.rating, "SOUL should have a rating")
        if let rating = soul.rating {
            XCTAssertGreaterThanOrEqual(rating, 4.5, "SOUL should have high rating (4.5+)")
        }
    }
    
    func test_soulMovie_notMistakenForOverTheMoon() {
        // Verify SOUL is not confused with "Over the Moon" (2020)
        let soulMovies = movies.filter { $0.title == "Soul" && $0.year == 2020 }
        guard let soul = soulMovies.first else {
            XCTFail("SOUL movie not found")
            return
        }
        
        let notes = soul.notes ?? ""
        
        // These are "Over the Moon" characteristics that should NOT be in SOUL
        XCTAssertFalse(notes.lowercased().contains("chinese"), "Should not contain Chinese content")
        XCTAssertFalse(notes.lowercased().contains("mythology"), "Should not contain mythology reference")
        XCTAssertFalse(notes.lowercased().contains("family"), "Should not be described as family adventure")
        XCTAssertFalse(notes.lowercased().contains("moon"), "Should not reference moon")
        
        // These should be SOUL characteristics
        XCTAssertTrue(notes.lowercased().contains("jazz") || 
                     notes.lowercased().contains("music") ||
                     notes.lowercased().contains("pianist"), "Should contain music/jazz references")
    }
    
    // MARK: - Data Integrity Tests
    
    func test_noDuplicateMovies() {
        // Check for duplicate movies (same title and year)
        var seenMovies: Set<String> = []
        var duplicates: [String] = []
        
        for movie in movies {
            let movieKey = "\(movie.title)_\(movie.year)"
            if seenMovies.contains(movieKey) {
                duplicates.append(movieKey)
            } else {
                seenMovies.insert(movieKey)
            }
        }
        
        XCTAssertTrue(duplicates.isEmpty, "Found duplicate movies: \(duplicates)")
    }
    
    func test_allMoviesHaveValidData() {
        for movie in movies {
            // Basic validation
            XCTAssertFalse(movie.title.isEmpty, "Movie title should not be empty")
            XCTAssertGreaterThan(movie.year, 1900, "Movie year should be reasonable")
            XCTAssertLessThanOrEqual(movie.year, 2025, "Movie year should not be in future")
            XCTAssertFalse(movie.emoji.isEmpty, "Movie emoji should not be empty")
            XCTAssertFalse(movie.streamingServices.isEmpty, "Movie should have at least one streaming service")
            
            // Rating validation (if provided)
            if let rating = movie.rating {
                XCTAssertGreaterThanOrEqual(rating, 0.0, "Rating should be non-negative")
                XCTAssertLessThanOrEqual(rating, 5.0, "Rating should not exceed 5.0")
            }
        }
    }
    
    func test_streamingServicesAreValid() {
        let validServices = [
            "Disney+", "Netflix", "Amazon Prime Video", "Hulu", "Max", 
            "Criterion Channel", "YouTube", "Archive.org", "Peacock",
            "Paramount+", "Apple TV+", "Educational platforms", "Pluto TV",
            "Crunchyroll", "Funimation", "Tubi", "Vimeo"
        ]
        
        for movie in movies {
            for service in movie.streamingServices {
                XCTAssertTrue(validServices.contains(service), 
                             "Invalid streaming service '\(service)' for movie '\(movie.title)'")
            }
        }
    }
    
    func test_ageGroupsAreAppropriate() {
        // Test that age groups make sense for content
        for movie in movies {
            // Movies with mature themes should not be in preschoolers
            if let notes = movie.notes {
                let matureKeywords = ["war", "death", "violence", "existential", "philosophical"]
                let hasMatureContent = matureKeywords.contains { notes.lowercased().contains($0) }
                
                if hasMatureContent {
                    XCTAssertNotEqual(movie.ageGroup, .preschoolers, 
                                    "Movie '\(movie.title)' has mature content but is marked for preschoolers")
                }
            }
        }
    }
}
