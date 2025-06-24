// DiscussionViewModel.swift - FIXED KEY PATH ISSUES
// HeyKidsWatchThis - Discussion View Model
// Following established @Observable ViewModel patterns

import SwiftUI

@Observable
class DiscussionViewModel {
    
    // MARK: - Published Properties
    
    private(set) var currentQuestions: [DiscussionQuestion] = []
    private(set) var selectedQuestion: DiscussionQuestion?
    private(set) var isLoading = false
    
    // Current discussion session
    var currentMemory: MemoryData?
    var currentChildAge: Int = 5
    var currentAnswer: String = ""
    
    // Filter properties
    var selectedAgeGroup: AgeGroup = .littleKids {
        didSet {
            loadQuestions()
        }
    }
    var selectedCategory: DiscussionQuestion.QuestionCategory?
    
    // MARK: - Dependencies
    
    private let discussionQuestionService: DiscussionQuestionServiceProtocol
    private let memoryService: MemoryServiceProtocol
    
    // MARK: - Initialization
    
    init(discussionQuestionService: DiscussionQuestionServiceProtocol, memoryService: MemoryServiceProtocol) {
        self.discussionQuestionService = discussionQuestionService
        self.memoryService = memoryService
        loadQuestions()
    }
    
    // MARK: - Question Loading
    
    func loadQuestions() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // FIXED: Use existing service methods instead of non-existent ones
            self.currentQuestions = self.discussionQuestionService.getQuestionsFor(ageGroup: self.selectedAgeGroup)
            
            // Apply category filter if set
            if let category = self.selectedCategory {
                self.currentQuestions = self.discussionQuestionService.getQuestionsByCategory(category)
            }
            
            self.isLoading = false
        }
    }
    
    func selectRandomQuestion() {
        selectedQuestion = currentQuestions.randomElement()
    }
    
    func selectQuestion(_ question: DiscussionQuestion) {
        selectedQuestion = question
    }
    
    // MARK: - Discussion Session Management
    
    func startDiscussionSession(for memory: MemoryData, childAge: Int) {
        currentMemory = memory
        currentChildAge = childAge
        currentAnswer = ""
        
        // Load questions appropriate for the child's age
        selectedAgeGroup = mapChildAgeToAgeGroup(childAge)
        loadQuestions()
        
        // Select a random starting question
        selectRandomQuestion()
    }
    
    func submitCurrentAnswer() -> Bool {
        guard let memory = currentMemory,
              let question = selectedQuestion,
              !currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        let answer = DiscussionAnswer(
            id: UUID(),
            questionId: question.id,
            response: currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines),
            childAge: currentChildAge
        )
        
        let success = memoryService.saveDiscussionAnswer(answer, for: memory.id)
        
        if success {
            // Clear current answer and select next question
            currentAnswer = ""
            selectRandomQuestion()
        }
        
        return success
    }
    
    func endDiscussionSession() {
        currentMemory = nil
        selectedQuestion = nil
        currentAnswer = ""
    }
    
    // MARK: - Filtering
    
    func filterByCategory(_ category: DiscussionQuestion.QuestionCategory?) {
        selectedCategory = category
        loadQuestions()
    }
    
    func clearFilters() {
        selectedCategory = nil
        loadQuestions()
    }
    
    // MARK: - Computed Properties
    
    var hasActiveSession: Bool {
        return currentMemory != nil
    }
    
    var canSubmitAnswer: Bool {
        return !currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var availableCategories: [DiscussionQuestion.QuestionCategory] {
        return DiscussionQuestion.QuestionCategory.allCases
    }
    
    var questionCountForCurrentFilters: Int {
        return currentQuestions.count
    }
    
    // MARK: - Age Group Mapping
    
    private func mapChildAgeToAgeGroup(_ age: Int) -> AgeGroup {
        switch age {
        case 2...4:
            return .preschoolers
        case 5...7:
            return .littleKids
        case 8...9:
            return .bigKids
        case 10...12:
            return .tweens
        default:
            return .littleKids // Default fallback
        }
    }
    
    // MARK: - Question Navigation
    
    func selectNextQuestion() {
        guard let currentQuestion = selectedQuestion,
              let currentIndex = currentQuestions.firstIndex(of: currentQuestion) else {
            selectRandomQuestion()
            return
        }
        
        let nextIndex = (currentIndex + 1) % currentQuestions.count
        selectedQuestion = currentQuestions[nextIndex]
    }
    
    func selectPreviousQuestion() {
        guard let currentQuestion = selectedQuestion,
              let currentIndex = currentQuestions.firstIndex(of: currentQuestion) else {
            selectRandomQuestion()
            return
        }
        
        let previousIndex = currentIndex == 0 ? currentQuestions.count - 1 : currentIndex - 1
        selectedQuestion = currentQuestions[previousIndex]
    }
    
    // MARK: - Question Statistics
    
    func getQuestionsByDifficulty(_ difficulty: DiscussionQuestion.QuestionDifficulty) -> [DiscussionQuestion] {
        return currentQuestions.filter { $0.difficulty == difficulty }
    }
    
    func getDifficultyDistribution() -> [DiscussionQuestion.QuestionDifficulty: Int] {
        var distribution: [DiscussionQuestion.QuestionDifficulty: Int] = [:]
        
        for difficulty in DiscussionQuestion.QuestionDifficulty.allCases {
            distribution[difficulty] = getQuestionsByDifficulty(difficulty).count
        }
        
        return distribution
    }
}

// MARK: - ObservableObject Conformance (for compatibility)
extension DiscussionViewModel: ObservableObject {
    // @Observable provides the objectWillChange publisher automatically
}
