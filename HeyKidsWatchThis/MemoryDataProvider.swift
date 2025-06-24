// MemoryDataProvider.swift - SURGICAL FIX - REMOVED DUPLICATE PROTOCOL
// HeyKidsWatchThis - Implementation only, protocol defined in MemoryServiceProtocol.swift

import Foundation

// ============================================================================
// MARK: - Memory Data Provider Implementation
// ============================================================================

class MemoryDataProvider: MemoryDataProviderProtocol {
    private let userDefaults: UserDefaultsStorageProtocol
    
    private let memoriesKey = "saved_memories"
    private let discussionAnswersKey = "discussion_answers"
    
    init(userDefaults: UserDefaultsStorageProtocol = UserDefaultsStorage()) {
        self.userDefaults = userDefaults
    }
    
    func loadMemories() -> [MemoryData] {
        return userDefaults.load([MemoryData].self, forKey: memoriesKey) ?? []
    }
    
    func saveMemories(_ memories: [MemoryData]) {
        _ = userDefaults.save(memories, forKey: memoriesKey)
    }
    
    func loadDiscussionAnswers() -> [DiscussionAnswer] {
        return userDefaults.load([DiscussionAnswer].self, forKey: discussionAnswersKey) ?? []
    }
    
    func saveDiscussionAnswers(_ answers: [DiscussionAnswer]) {
        _ = userDefaults.save(answers, forKey: discussionAnswersKey)
    }
}
