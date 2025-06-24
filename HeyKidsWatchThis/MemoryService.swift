// MemoryService.swift
// HeyKidsWatchThis - Phase 1: TDD Compilation Fix
// @Observable MemoryService using modern iOS 17+ patterns
// Updated to fix compilation errors and use proper method signatures

import Foundation
import Observation

@Observable
class MemoryService: MemoryServiceProtocol {
    
    private let dataProvider: MemoryDataProviderProtocol
    
    // MARK: - Public Read-Only Properties (Fix for access control)
    public private(set) var memories: [MemoryData] = []
    
    // MARK: - Private Implementation Properties
    private var discussionAnswers: [DiscussionAnswer] = []
    
    // MARK: - Initialization
    
    init(dataProvider: MemoryDataProviderProtocol) {
        self.dataProvider = dataProvider
        loadMemories()
    }
    
    // MARK: - Core Memory Operations
    
    func getAllMemories() -> [MemoryData] {
        return memories
    }
    
    func getMemories(for movieId: UUID) -> [MemoryData] {
        return memories.filter { $0.movieId == movieId }
    }
    
    func getMemory(by id: UUID) -> MemoryData? {
        return memories.first { $0.id == id }
    }
    
    @discardableResult
    func createMemory(_ memory: MemoryData) -> Bool {
        memories.append(memory)
        dataProvider.saveMemories(memories)
        return true
    }
    
    @discardableResult
    func deleteMemory(_ id: UUID) -> Bool {
        let initialCount = memories.count
        memories.removeAll { $0.id == id }
        
        if memories.count < initialCount {
            dataProvider.saveMemories(memories)
            return true
        }
        return false
    }
    
    @discardableResult
    func loadMemories() -> [MemoryData] {
        memories = dataProvider.loadMemories()
        discussionAnswers = dataProvider.loadDiscussionAnswers()
        return memories
    }
    
    // MARK: - Discussion Operations
    
    @discardableResult
    func saveDiscussionAnswer(_ answer: DiscussionAnswer, for memoryId: UUID) -> Bool {
        // Remove existing answer for this question and memory
        discussionAnswers.removeAll { 
            $0.questionId == answer.questionId && 
            getMemory(by: memoryId) != nil 
        }
        
        // Add new answer
        discussionAnswers.append(answer)
        dataProvider.saveDiscussionAnswers(discussionAnswers)
        return true
    }
    
    func getDiscussionAnswers(for memoryId: UUID) -> [DiscussionAnswer] {
        guard let memory = getMemory(by: memoryId) else { return [] }
        return memory.discussionAnswers
    }
    
    // MARK: - Memory Statistics
    
    func getMemoryCount() -> Int {
        return memories.count
    }
    
    func getAverageRating() -> Double {
        guard !memories.isEmpty else { return 0.0 }
        let totalRating = memories.reduce(0) { $0 + $1.rating }
        return Double(totalRating) / Double(memories.count)
    }
    
    func getMemoriesSorted(by criteria: MemorySortCriteria) -> [MemoryData] {
        switch criteria {
        case .date:
            return memories.sorted { $0.watchDate > $1.watchDate }
        case .rating:
            return memories.sorted { $0.rating > $1.rating }
        case .movieTitle:
            return memories.sorted { memory1, memory2 in
                // This would require movie service integration
                // For now, sort by watch date as fallback
                return memory1.watchDate > memory2.watchDate
            }
        }
    }
    
    func searchMemories(query: String) -> [MemoryData] {
        guard !query.isEmpty else { return memories }
        
        let lowercaseQuery = query.lowercased()
        return memories.filter { memory in
            memory.notes?.lowercased().contains(lowercaseQuery) == true
        }
    }
}

// MARK: - Mock Memory Data Provider extension removed - using separate MockMemoryDataProvider.swift file
