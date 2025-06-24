// HapticFeedbackTests.swift - TDD RED Phase
// Tests that should initially fail, then pass after implementation

import XCTest
import UIKit
@testable import HeyKidsWatchThis

final class HapticFeedbackTests: XCTestCase {
    
    var hapticManager: HapticFeedbackManager!
    
    override func setUpWithError() throws {
        hapticManager = HapticFeedbackManager.shared
    }
    
    override func tearDownWithError() throws {
        hapticManager = nil
    }
    
    // MARK: - Initialization Tests
    
    func testHapticManagerInitialization() {
        // Given & When
        let manager = HapticFeedbackManager.shared
        
        // Then
        XCTAssertNotNil(manager, "HapticFeedbackManager should initialize successfully")
    }
    
    func testHapticManagerSingleton() {
        // Given & When
        let manager1 = HapticFeedbackManager.shared
        let manager2 = HapticFeedbackManager.shared
        
        // Then
        XCTAssertTrue(manager1 === manager2, "HapticFeedbackManager should be a singleton")
    }
    
    // MARK: - Selection Feedback Tests
    
    func testSelectionFeedbackTrigger() {
        // Given
        let expectation = XCTestExpectation(description: "Selection feedback should trigger without crashing")
        
        // When
        DispatchQueue.main.async {
            self.hapticManager.triggerSelection()
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        // Test passes if no crash occurs
    }
    
    // MARK: - Impact Feedback Tests
    
    func testImpactFeedbackWithDifferentStyles() {
        // Given
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy]
        let expectation = XCTestExpectation(description: "Impact feedback should work with all styles")
        expectation.expectedFulfillmentCount = styles.count
        
        // When & Then
        for style in styles {
            DispatchQueue.main.async {
                self.hapticManager.triggerImpact(style: style)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testDefaultImpactFeedback() {
        // Given
        let expectation = XCTestExpectation(description: "Default impact feedback should work")
        
        // When
        DispatchQueue.main.async {
            self.hapticManager.triggerImpact() // Uses default .medium style
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Notification Feedback Tests
    
    func testNotificationFeedbackTypes() {
        // Given
        let expectation = XCTestExpectation(description: "All notification types should work")
        expectation.expectedFulfillmentCount = 3 // success, error, warning
        
        // When & Then
        DispatchQueue.main.async {
            self.hapticManager.triggerSuccess()
            expectation.fulfill()
            
            self.hapticManager.triggerError()
            expectation.fulfill()
            
            self.hapticManager.triggerWarning()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSuccessFeedback() {
        // Given
        let expectation = XCTestExpectation(description: "Success feedback should trigger")
        
        // When
        DispatchQueue.main.async {
            self.hapticManager.triggerSuccess()
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorFeedback() {
        // Given
        let expectation = XCTestExpectation(description: "Error feedback should trigger")
        
        // When
        DispatchQueue.main.async {
            self.hapticManager.triggerError()
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWarningFeedback() {
        // Given
        let expectation = XCTestExpectation(description: "Warning feedback should trigger")
        
        // When
        DispatchQueue.main.async {
            self.hapticManager.triggerWarning()
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Thread Safety Tests
    
    func testHapticCallsFromBackgroundQueue() {
        // Given
        let expectation = XCTestExpectation(description: "Haptic calls should be thread-safe")
        expectation.expectedFulfillmentCount = 3
        
        // When - Call from background queue
        DispatchQueue.global(qos: .background).async {
            self.hapticManager.triggerSelection()
            expectation.fulfill()
            
            self.hapticManager.triggerImpact(style: .light)
            expectation.fulfill()
            
            self.hapticManager.triggerSuccess()
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Performance Tests
    
    func testHapticPerformanceOptimization() {
        // Given
        let iterations = 10
        let expectation = XCTestExpectation(description: "Multiple haptic calls should complete quickly")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // When
        DispatchQueue.main.async {
            for _ in 0..<iterations {
                self.hapticManager.triggerSelection()
            }
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            // Then - Should complete within reasonable time (< 1 second)
            XCTAssertLessThan(timeElapsed, 1.0, "Multiple haptic calls should complete quickly")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() {
        // Given & When
        weak var weakManager: HapticFeedbackManager?
        
        autoreleasepool {
            let manager = HapticFeedbackManager.shared
            weakManager = manager
            
            // Trigger some haptics
            manager.triggerSelection()
            manager.triggerSuccess()
        }
        
        // Then - Singleton should still exist
        XCTAssertNotNil(weakManager, "Singleton should persist")
    }
    
    // MARK: - Integration Tests
    
    func testHapticIntegrationWithUI() {
        // Given
        let expectation = XCTestExpectation(description: "Haptics should integrate well with UI actions")
        
        // When - Simulate UI interactions
        DispatchQueue.main.async {
            // Simulate button tap
            self.hapticManager.triggerImpact(style: .medium)
            
            // Simulate selection change
            self.hapticManager.triggerSelection()
            
            // Simulate success action
            self.hapticManager.triggerSuccess()
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Objects for Testing

class MockHapticFeedbackManager: HapticFeedbackManagerProtocol {
    var selectionCallCount = 0
    var impactCallCount = 0
    var successCallCount = 0
    var errorCallCount = 0
    var warningCallCount = 0
    
    func triggerSelection() {
        selectionCallCount += 1
    }
    
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        impactCallCount += 1
    }
    
    func triggerSuccess() {
        successCallCount += 1
    }
    
    func triggerError() {
        errorCallCount += 1
    }
    
    func triggerWarning() {
        warningCallCount += 1
    }
}