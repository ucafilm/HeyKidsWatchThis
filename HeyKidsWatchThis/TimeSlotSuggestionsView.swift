// TimeSlotSuggestionsView.swift
// HeyKidsWatchThis - SIMPLIFIED VERSION WITHOUT COMPLEX DEPENDENCIES
// Removed EventKit dependencies to focus on core functionality

import SwiftUI

// MARK: - Simple Time Slot Suggestion

struct SimpleTimeSlotSuggestion {
    let startTime: Date
    let endTime: Date
    let title: String
    let description: String
    let score: Int
}

// MARK: - Time Slot Suggestions View

struct TimeSlotSuggestionsView: View {
    let suggestions: [SimpleTimeSlotSuggestion]
    let movie: MovieData
    let onTimeSlotSelected: (SimpleTimeSlotSuggestion) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Smart Time Suggestions")
                        .font(.title2.bold())
                    
                    Text("For \(movie.title)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                // Suggestions List
                if suggestions.isEmpty {
                    ContentUnavailableView(
                        "No Suggestions Available",
                        systemImage: "clock.badge.xmark",
                        description: Text("Try selecting a different date.")
                    )
                } else {
                    List(suggestions, id: \.startTime) { suggestion in
                        SimpleTimeSlotRow(
                            suggestion: suggestion,
                            isSelected: false,
                            onTap: {
                                onTimeSlotSelected(suggestion)
                                dismiss()
                            }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Simple Time Slot Row

struct SimpleTimeSlotRow: View {
    let suggestion: SimpleTimeSlotSuggestion
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    
                    Text(suggestion.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(suggestion.score)")
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentColor)
                    
                    Text("score")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : .secondary.opacity(0.05))
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    TimeSlotSuggestionsView(
        suggestions: [
            SimpleTimeSlotSuggestion(
                startTime: Date(),
                endTime: Date().addingTimeInterval(7200),
                title: "Tonight at 7:00 PM",
                description: "Perfect family time after dinner",
                score: 85
            ),
            SimpleTimeSlotSuggestion(
                startTime: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                endTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())?.addingTimeInterval(7200) ?? Date(),
                title: "Tomorrow at 6:30 PM",
                description: "Good for weekend viewing",
                score: 75
            )
        ],
        movie: MovieData(
            title: "Sample Movie",
            year: 2023,
            ageGroup: .bigKids,
            genre: "Animation",
            emoji: "🎬",
            streamingServices: ["Disney+"],
            rating: 4.5,
            notes: "Sample movie for preview"
        ),
        onTimeSlotSelected: { _ in }
    )
}
