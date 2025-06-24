import SwiftUI
import Foundation

// Removed @MainActor - @Observable handles threading automatically in iOS 17+
@Observable
class PerformanceMonitor {
    
    var lastUpdateDuration: TimeInterval = 0
    var averageUpdateDuration: TimeInterval = 0
    var updateCount: Int = 0
    
    private var updateDurations: [TimeInterval] = []
    private let maxDurationHistory = 100
    
    // Synchronous measurement - no @MainActor needed
    func measure<T>(_ operation: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let duration = endTime - startTime
        recordUpdateDuration(duration)
        
        return result
    }
    
    // Async measurement with proper actor isolation
    func measureAsync<T>(_ operation: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let duration = endTime - startTime
        await recordUpdateDurationAsync(duration)
        
        return result
    }
    
    // Private synchronous version
    private func recordUpdateDuration(_ duration: TimeInterval) {
        lastUpdateDuration = duration
        updateCount += 1
        
        updateDurations.append(duration)
        if updateDurations.count > maxDurationHistory {
            updateDurations.removeFirst()
        }
        
        averageUpdateDuration = updateDurations.reduce(0, +) / Double(updateDurations.count)
    }
    
    // Private async version to handle async calls
    @MainActor
    private func recordUpdateDurationAsync(_ duration: TimeInterval) {
        recordUpdateDuration(duration)
    }
    
    var isPerformanceGood: Bool {
        averageUpdateDuration < 0.016 // 60fps = 16ms per frame
    }
    
    func reset() {
        updateDurations.removeAll()
        lastUpdateDuration = 0
        averageUpdateDuration = 0
        updateCount = 0
    }
}
