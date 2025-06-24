// MockMemoryDataProvider.swift
// HeyKidsWatchThis - Missing MockMemoryDataProvider Implementation
// COMPILATION FIX: Added missing MockMemoryDataProvider class

import Foundation

/// Mock implementation of MemoryDataProviderProtocol for testing and development
class MockMemoryDataProvider: MemoryDataProviderProtocol {
    private var memories: [MemoryData] = []
    private var discussionAnswers: [DiscussionAnswer] = []
    
    // MARK: - MemoryDataProviderProtocol Implementation
    
    func loadMemories() -> [MemoryData] {
        return memories
    }
    
    func saveMemories(_ memories: [MemoryData]) {
        self.memories = memories
    }
    
    func loadDiscussionAnswers() -> [DiscussionAnswer] {
        return discussionAnswers
    }
    
    func saveDiscussionAnswers(_ answers: [DiscussionAnswer]) {
        self.discussionAnswers = answers
    }
    
    // MARK: - Test Helper Methods
    
    /// Adds a memory for testing purposes
    func addMemory(_ memory: MemoryData) {
        memories.append(memory)
    }
    
    /// Clears all data for testing
    func clearAllData() {
        memories.removeAll()
        discussionAnswers.removeAll()
    }
    
    /// Gets memory count for testing
    func getMemoryCount() -> Int {
        return memories.count
    }
}
