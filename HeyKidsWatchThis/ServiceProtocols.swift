// ServiceProtocols.swift - SURGICAL FIX
// Essential service protocols only - NO duplicate definitions

import Foundation

// MARK: - Discussion Service Protocol (Essential only)

/// Protocol for discussion question management
protocol DiscussionQuestionServiceProtocol {
    func getQuestionsFor(ageGroup: AgeGroup) -> [DiscussionQuestion]
    func getQuestionsByCategory(_ category: DiscussionQuestion.QuestionCategory) -> [DiscussionQuestion]
}

// NOTE: All other protocols (Memory, Movie, Navigation) are defined in their respective files
// This file only contains discussion-related protocols to avoid conflicts
