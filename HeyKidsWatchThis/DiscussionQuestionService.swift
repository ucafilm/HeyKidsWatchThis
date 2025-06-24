// DiscussionQuestionService.swift - SURGICAL FIX - ADDED EQUATABLE
// Clean implementation without conflicting definitions

import Foundation

/// Discussion question model (SINGLE DEFINITION) - NOW WITH EQUATABLE
struct DiscussionQuestion: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let category: QuestionCategory
    let difficulty: QuestionDifficulty
    let ageGroup: AgeGroup
    
    init(text: String, category: QuestionCategory, difficulty: QuestionDifficulty, ageGroup: AgeGroup) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.difficulty = difficulty
        self.ageGroup = ageGroup
    }
    
    // MARK: - Equatable Conformance (Automatic via ID)
    // Since this struct has UUID id and all other properties are Equatable,
    // Swift automatically synthesizes the == operator
    
    enum QuestionCategory: String, CaseIterable, Codable {
        case emotions = "emotions"
        case morals = "morals"
        case creativity = "creativity"
        case learning = "learning"
        case family = "family"
        case friendship = "friendship"
        case adventure = "adventure"
        case general = "general"
        
        var displayName: String {
            return rawValue.capitalized
        }
    }
    
    enum QuestionDifficulty: String, CaseIterable, Codable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
    }
}

/// Discussion question service implementation
class DiscussionQuestionService: DiscussionQuestionServiceProtocol {
    
    private let questions: [DiscussionQuestion] = [
        DiscussionQuestion(
            text: "What was your favorite part of the movie?",
            category: .emotions,
            difficulty: .easy,
            ageGroup: .preschoolers
        ),
        DiscussionQuestion(
            text: "How do you think the character felt when they faced their challenge?",
            category: .emotions,
            difficulty: .medium,
            ageGroup: .littleKids
        ),
        DiscussionQuestion(
            text: "What would you have done differently if you were the main character?",
            category: .creativity,
            difficulty: .medium,
            ageGroup: .bigKids
        ),
        DiscussionQuestion(
            text: "What lesson do you think the movie was trying to teach us?",
            category: .morals,
            difficulty: .hard,
            ageGroup: .tweens
        )
    ]
    
    func getQuestionsFor(ageGroup: AgeGroup) -> [DiscussionQuestion] {
        return questions.filter { $0.ageGroup == ageGroup }
    }
    
    func getQuestionsByCategory(_ category: DiscussionQuestion.QuestionCategory) -> [DiscussionQuestion] {
        return questions.filter { $0.category == category }
    }
}
