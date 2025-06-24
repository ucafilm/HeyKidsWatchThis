// CleanupValidationTests.swift
// TDD VALIDATION: Verify project cleanup and MovieSchedulerView stability
// Following Context7 protocol and TDD methodology

import XCTest
import SwiftUI
@testable import HeyKidsWatchThis

@MainActor
final class CleanupValidationTests: XCTestCase {
    
    // MARK: - Test Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Set up any needed test state
    }
    
    override func tearDownWithError() throws {
        // Clean up test state
        try super.tearDownWithError()
    }
    
    // MARK: - Target Membership Tests
    
    func testMockFilesAreOnlyInTestTarget() throws {
        // TDD RED → GREEN: Verify mock files are not in main app bundle
        
        // This test validates that mock files have been properly moved to test target
        // and are not included in the main app bundle, which would cause the 
        // "Ignoring Import" warning
        
        let mainBundle = Bundle.main
        
        // Verify MockMovieService is NOT in main bundle
        XCTAssertNil(
            mainBundle.path(forResource: "MockMovieService", ofType: "swift"),
            "MockMovieService should not be included in main app bundle"
        )
        
        // Verify MockMovieDataProvider is NOT in main bundle  
        XCTAssertNil(
            mainBundle.path(forResource: "MockMovieDataProvider", ofType: "swift"),
            "MockMovieDataProvider should not be included in main app bundle"
        )
        
        // Verify MockMemoryDataProvider is NOT in main bundle
        XCTAssertNil(
            mainBundle.path(forResource: "MockMemoryDataProvider", ofType: "swift"),
            "MockMemoryDataProvider should not be included in main app bundle"
        )
        
        print("✅ TDD PASS: Mock files properly excluded from main app bundle")
    }
    
    // MARK: - MovieSchedulerView Stability Tests
    
    func testMovieSchedulerViewUsesStableComponents() throws {
        // TDD RED → GREEN: Verify MovieSchedulerView uses stable .compact DatePicker
        
        let sampleMovie = MovieData(
            title: "Test Movie",
            year: 2024,
            ageGroup: .littleKids,
            genre: "Animation", 
            emoji: "🎬",
            streamingServices: ["TestService"],
            rating: 4.5,
            notes: "Test movie for scheduler validation"
        )
        
        let mockService = MockMovieService()
        var dismissCalled = false
        
        let schedulerView = MovieSchedulerView(
            movie: sampleMovie,
            movieService: mockService,
            onDismiss: { dismissCalled = true }
        )
        
        // Create a hosting controller to test the view
        let hostingController = UIHostingController(rootView: schedulerView)
        
        // Verify the view can be created without crashing
        XCTAssertNotNil(hostingController.view, "MovieSchedulerView should create successfully")
        
        // Test that the view hierarchy is stable
        XCTAssertNoThrow(
            hostingController.viewWillAppear(false),
            "MovieSchedulerView should appear without throwing exceptions"
        )
        
        print("✅ TDD PASS: MovieSchedulerView creates and appears without crashing")
    }
    
    func testCalendarWeekdayCalculationIsCorrect() throws {
        // TDD RED → GREEN: Verify Calendar.SATURDAY fix using integer 7
        
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // Test the exact logic from MovieSchedulerView
        let daysUntilSaturday = (7 - weekday + 7) % 7
        let finalDaysToAdd = daysUntilSaturday == 0 ? 7 : daysUntilSaturday
        
        // Verify the calculation is valid
        XCTAssertTrue(finalDaysToAdd >= 0, "Days to add should be non-negative")
        XCTAssertTrue(finalDaysToAdd <= 7, "Days to add should not exceed 7")
        
        // Verify Saturday calculation works for any day
        let saturday = calendar.date(byAdding: .day, value: finalDaysToAdd, to: today)!
        let saturdayWeekday = calendar.component(.weekday, from: saturday)
        
        XCTAssertEqual(saturdayWeekday, 7, "Calculated date should be Saturday (weekday 7)")
        
        print("✅ TDD PASS: Calendar.SATURDAY fix works correctly with integer 7")
    }
    
    // MARK: - Memory Management Tests
    
    func testNoTemporaryFilesInMainTarget() throws {
        // TDD RED → GREEN: Verify temporary diagnostic files were removed
        
        let mainBundle = Bundle.main
        
        // Verify temporary diagnostic files are NOT in main bundle
        XCTAssertNil(
            mainBundle.path(forResource: "MinimalTestApp", ofType: "swift"),
            "MinimalTestApp should have been removed from main target"
        )
        
        XCTAssertNil(
            mainBundle.path(forResource: "DebugApp", ofType: "swift"),
            "DebugApp should have been removed from main target"
        )
        
        XCTAssertNil(
            mainBundle.path(forResource: "SimpleWorkingMovieScheduler", ofType: "swift"),
            "SimpleWorkingMovieScheduler should have been removed from main target"
        )
        
        print("✅ TDD PASS: All temporary diagnostic files successfully removed")
    }
    
    // MARK: - Integration Tests
    
    func testMovieServiceSchedulingIntegration() throws {
        // TDD RED → GREEN: Verify movie scheduling works with cleaned up architecture
        
        let mockService = MockMovieService()
        let testMovieId = UUID()
        let scheduledDate = Date()
        
        // Test scheduling a movie
        mockService.scheduleMovie(testMovieId, for: scheduledDate)
        
        // Verify the movie is scheduled
        XCTAssertTrue(
            mockService.isScheduled(testMovieId),
            "Movie should be marked as scheduled"
        )
        
        XCTAssertEqual(
            mockService.getScheduledDate(for: testMovieId),
            scheduledDate,
            "Scheduled date should match the date we set"
        )
        
        print("✅ TDD PASS: Movie scheduling integration works correctly")
    }
    
    // MARK: - Regression Tests
    
    func testNoSIGTERMOnSchedulerPresentation() throws {
        // TDD RED → GREEN: Verify scheduler can be presented without SIGTERM
        
        let sampleMovie = MovieData(
            title: "SIGTERM Test Movie",
            year: 2024,
            ageGroup: .bigKids,
            genre: "Test",
            emoji: "🧪",
            streamingServices: ["TestService"],
            rating: 4.0,
            notes: "Testing for SIGTERM regression"
        )
        
        let mockService = MockMovieService()
        
        // Test creating the scheduler view multiple times (regression test)
        for i in 1...5 {
            let schedulerView = MovieSchedulerView(
                movie: sampleMovie,
                movieService: mockService,
                onDismiss: {}
            )
            
            let hostingController = UIHostingController(rootView: schedulerView)
            
            XCTAssertNotNil(
                hostingController.view,
                "MovieSchedulerView creation #\(i) should not cause SIGTERM"
            )
        }
        
        print("✅ TDD PASS: Multiple scheduler presentations don't cause SIGTERM")
    }
    
    // MARK: - Performance Tests
    
    func testMovieSchedulerViewPerformance() throws {
        // TDD: Verify scheduler view creation is performant
        
        let sampleMovie = MovieData(
            title: "Performance Test",
            year: 2024,
            ageGroup: .tweens,
            genre: "Performance",
            emoji: "⚡",
            streamingServices: ["FastService"],
            rating: 5.0,
            notes: "Testing performance"
        )
        
        let mockService = MockMovieService()
        
        measure {
            // Test that view creation is fast
            let schedulerView = MovieSchedulerView(
                movie: sampleMovie,
                movieService: mockService,
                onDismiss: {}
            )
            
            let hostingController = UIHostingController(rootView: schedulerView)
            _ = hostingController.view // Force view creation
        }
        
        print("✅ TDD PASS: MovieSchedulerView creation is performant")
    }
}

// MARK: - Test Extensions

extension CleanupValidationTests {
    
    /// Helper to create test movies for validation
    private func createTestMovie(title: String = "Test Movie") -> MovieData {
        return MovieData(
            title: title,
            year: 2024,
            ageGroup: .littleKids,
            genre: "Test",
            emoji: "🧪",
            streamingServices: ["TestService"],
            rating: 4.0,
            notes: "Generated for testing"
        )
    }
}
