// DiscussionView.swift - COMPLETE FIXED VERSION
// HeyKidsWatchThis - Discussion View
// Family discussion interface following established patterns with proper DI

import SwiftUI

struct DiscussionView: View {
    let memory: MemoryData
    @Bindable var memoryViewModel: MemoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var discussionViewModel: DiscussionViewModel
    @State private var selectedChildAge: Int = 7
    @State private var currentAnswer: String = ""
    @State private var isSubmitting = false
    
    // FIXED: Proper dependency injection using public service access
    init(memory: MemoryData, memoryViewModel: MemoryViewModel) {
        self.memory = memory
        self.memoryViewModel = memoryViewModel
        
        // FIXED: Access public services from memoryViewModel
        let discussionService = DiscussionQuestionService()
        let memoryService = memoryViewModel.memoryService  // Now public
        
        self._discussionViewModel = State(initialValue: DiscussionViewModel(
            discussionQuestionService: discussionService,
            memoryService: memoryService
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Discussion Header
                DiscussionHeaderView(
                    movie: memoryViewModel.getMovie(for: memory),
                    selectedAge: $selectedChildAge
                )
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Main Discussion Content
                if discussionViewModel.isLoading {
                    DiscussionLoadingView()  // FIXED: Now exists
                } else {
                    DiscussionContentView(
                        viewModel: discussionViewModel,
                        selectedChildAge: selectedChildAge,
                        currentAnswer: $currentAnswer,
                        isSubmitting: $isSubmitting,
                        onSubmitAnswer: { submitAnswer() }
                    )
                }
            }
            .navigationTitle("Family Discussion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(DiscussionQuestion.QuestionCategory.allCases, id: \.self) { category in
                            Button(category.displayName) {
                                discussionViewModel.filterByCategory(category)
                            }
                        }
                        
                        Divider()
                        
                        Button("All Questions") {
                            discussionViewModel.clearFilters()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear {
                discussionViewModel.startDiscussionSession(for: memory, childAge: selectedChildAge)
            }
        }
    }
    
    private func submitAnswer() {
        guard !currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSubmitting = true
        
        let answer = DiscussionAnswer(
            questionId: discussionViewModel.selectedQuestion?.id ?? UUID(),
            response: currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines),
            childAge: selectedChildAge
        )
        
        let success = memoryViewModel.addDiscussionAnswer(answer, to: memory)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            
            if success {
                currentAnswer = ""
                discussionViewModel.selectRandomQuestion()
                HapticFeedbackManager.shared.triggerSuccess()  // FIXED: Use correct manager
            } else {
                HapticFeedbackManager.shared.triggerError()    // FIXED: Use correct manager
            }
        }
    }
}

// MARK: - Discussion Header View

struct DiscussionHeaderView: View {
    let movie: MovieData?
    @Binding var selectedAge: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                if let movie = movie {
                    Text(movie.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(movie.title)
                            .font(.headline)
                        Text("Family Discussion")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Age Selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Child's Age")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    ForEach([4, 6, 8, 10, 12], id: \.self) { age in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedAge = age
                            }
                        } label: {
                            Text("\(age)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedAge == age ? Color.blue : Color(.systemGray5))
                                )
                                .foregroundColor(selectedAge == age ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Discussion Content View

struct DiscussionContentView: View {
    @Bindable var viewModel: DiscussionViewModel
    let selectedChildAge: Int
    @Binding var currentAnswer: String
    @Binding var isSubmitting: Bool
    let onSubmitAnswer: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Question Section
                if let question = viewModel.selectedQuestion {
                    CurrentQuestionView(
                        question: question,
                        answer: $currentAnswer,
                        isSubmitting: isSubmitting,
                        onSubmit: onSubmitAnswer,
                        onNextQuestion: { viewModel.selectNextQuestion() },
                        onPreviousQuestion: { viewModel.selectPreviousQuestion() }
                    )
                } else {
                    QuestionSelectionView(viewModel: viewModel)
                }
                
                Divider()
                
                // Available Questions
                AvailableQuestionsView(viewModel: viewModel)
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
}

// MARK: - Current Question View

struct CurrentQuestionView: View {
    let question: DiscussionQuestion
    @Binding var answer: String
    let isSubmitting: Bool
    let onSubmit: () -> Void
    let onNextQuestion: () -> Void
    let onPreviousQuestion: () -> Void
    
    private var canSubmit: Bool {
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Discussion Question")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Question Category
                    Text(question.category.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Difficulty indicator
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { level in
                        Circle()
                            .fill(level <= difficultyLevel(question.difficulty) ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    
                    Text(question.difficulty.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // Question Text
            Text(question.text)
                .font(.title3)
                .fontWeight(.medium)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            // Answer Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Answer")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextEditor(text: $answer)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if answer.isEmpty {
                                Text("Share your thoughts...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Navigation Buttons
                HStack(spacing: 8) {
                    Button {
                        onPreviousQuestion()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    
                    Button {
                        onNextQuestion()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Submit Button
                EnhancedPressableButton(
                    title: isSubmitting ? "Saving..." : "Save Answer",
                    style: .primary
                ) {
                    onSubmit()
                }
                .disabled(!canSubmit)
            }
        }
    }
    
    private func difficultyLevel(_ difficulty: DiscussionQuestion.QuestionDifficulty) -> Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

// MARK: - Question Selection View

struct QuestionSelectionView: View {
    @Bindable var viewModel: DiscussionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Choose a Discussion Question")
                .font(.headline)
            
            Text("Pick a question to start your family discussion")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            EnhancedPressableButton(
                title: "Get Random Question",
                style: .primary
            ) {
                viewModel.selectRandomQuestion()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Available Questions View

struct AvailableQuestionsView: View {
    @Bindable var viewModel: DiscussionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available Questions")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.questionCountForCurrentFilters) question\(viewModel.questionCountForCurrentFilters == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.currentQuestions.isEmpty {
                Text("No questions available for the selected age group and filters.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.currentQuestions) { question in
                        QuestionRowView(
                            question: question,
                            isSelected: question.id == viewModel.selectedQuestion?.id
                        ) {
                            viewModel.selectQuestion(question)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Question Row View

struct QuestionRowView: View {
    let question: DiscussionQuestion
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(question.category.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    // Difficulty dots
                    HStack(spacing: 2) {
                        ForEach(1...3, id: \.self) { level in
                            Circle()
                                .fill(level <= difficultyLevel(question.difficulty) ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                
                Text(question.text)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func difficultyLevel(_ difficulty: DiscussionQuestion.QuestionDifficulty) -> Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

// MARK: - Preview

#Preview {
    DiscussionView(
        memory: MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 5,
            notes: "Great family movie!"
        ),
        memoryViewModel: MemoryViewModel(
            memoryService: MemoryService(dataProvider: MemoryDataProvider()),
            movieService: MovieService(dataProvider: MovieDataProvider())
        )
    )
}
