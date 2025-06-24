// MemoryServiceProtocol.swift - SURGICAL FIX - ADDED MISSING loadMemories() METHOD
// HeyKidsWatchThis - Memory Service Protocol
// Following established MovieServiceProtocol patterns

import Foundation

/// Memory service protocol following established service patterns
protocol MemoryServiceProtocol {
    // Core memory operations
    func getAllMemories() -> [MemoryData]
    func getMemories(for movieId: UUID) -> [MemoryData]
    func getMemory(by id: UUID) -> MemoryData?
    func createMemory(_ memory: MemoryData) -> Bool
    func deleteMemory(_ id: UUID) -> Bool
    
    // SURGICAL FIX: Added missing loadMemories() method
    func loadMemories() -> [MemoryData]
    
    // Discussion operations
    func saveDiscussionAnswer(_ answer: DiscussionAnswer, for memoryId: UUID) -> Bool
    func getDiscussionAnswers(for memoryId: UUID) -> [DiscussionAnswer]
    
    // Memory statistics
    func getMemoryCount() -> Int
    func getAverageRating() -> Double
    func getMemoriesSorted(by criteria: MemorySortCriteria) -> [MemoryData]
    func searchMemories(query: String) -> [MemoryData]
}

/// Memory sorting criteria following established patterns
enum MemorySortCriteria {
    case date
    case rating
    case movieTitle
}

/// Memory data provider protocol following established patterns
protocol MemoryDataProviderProtocol {
    func loadMemories() -> [MemoryData]
    func saveMemories(_ memories: [MemoryData])
    func loadDiscussionAnswers() -> [DiscussionAnswer]
    func saveDiscussionAnswers(_ answers: [DiscussionAnswer])
}
