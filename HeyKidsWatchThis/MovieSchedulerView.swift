// MovieSchedulerView.swift
// FINAL DEFINITIVE VERSION 2
// Now accepts CalendarService directly as a parameter for improved stability.

import SwiftUI

struct MovieSchedulerView: View {
    // MARK: - Properties
    let movie: MovieData
    let movieService: MovieServiceProtocol
    // ✅ FIX: Accept CalendarService as a direct parameter.
    let calendarService: CalendarService
    let onDismiss: () -> Void
    
    @State private var selectedDate = Date()
    @State private var isScheduling = false
    @State private var alertType: SchedulerAlertType?
    @State private var selectedTimeOption = "Tonight at 7 PM"

    private let timeOptions = ["Tonight at 7 PM", "Tomorrow at 7 PM", "This Weekend", "Custom Date..."]

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header with dismiss button
            HStack {
                Button("Cancel", action: onDismiss)
                Spacer()
                Text("Schedule Movie").font(.headline)
                Spacer()
                Button("Done") { scheduleMovie() }.disabled(isScheduling).fontWeight(.bold)
            }
            .padding()
            .background(Color(.systemGray6))

            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text(movie.emoji).font(.system(size: 60))
                        Text(movie.title).font(.title2).bold().multilineTextAlignment(.center)
                        Text("\(movie.ageGroup.description) • \(movie.genre)").font(.caption).foregroundStyle(.secondary)
                    }.padding(.top)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("When would you like to watch?").font(.headline)
                        ForEach(timeOptions, id: \.self) { option in
                            Button(action: { selectedTimeOption = option }) {
                                HStack {
                                    Text(option).foregroundStyle(.primary)
                                    Spacer()
                                    if selectedTimeOption == option { Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue) }
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(selectedTimeOption == option ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground)))
                            .buttonStyle(.plain)
                        }
                    }
                    
                    if selectedTimeOption == "Custom Date..." {
                        DatePicker(
                            "Select Date & Time",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .padding(.top, 10)
                    }
                }
                .padding()
            }
            
            Button(action: scheduleMovie) {
                HStack {
                    if isScheduling {
                        ProgressView().tint(.white)
                    }
                    Text(isScheduling ? "Scheduling..." : "Schedule Movie Night").bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.gradient)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding()
            .disabled(isScheduling)
        }
        .background(Color(.systemGroupedBackground))
        .alert(item: $alertType) { type in
            switch type {
            case .success(let message):
                return Alert(title: Text("Movie Scheduled!"), message: Text(message), dismissButton: .default(Text("Great!"), action: onDismiss))
            case .failure(let message):
                return Alert(title: Text("Scheduling Failed"), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Actions
    
    private func scheduleMovie() {
        isScheduling = true
        let finalDate = calculateSelectedDate()
        
        movieService.scheduleMovie(movie.id, for: finalDate)
        let calendarSuccess = calendarService.createMovieNightEvent(for: movie, at: finalDate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isScheduling = false
            if calendarSuccess {
                HapticFeedbackManager.shared.triggerSuccess()
                alertType = .success("\(movie.title) has been added to your calendar for \(formatSelectedDate()).")
            } else {
                HapticFeedbackManager.shared.triggerError()
                alertType = .failure("The movie was saved in the app, but could not be added to your iOS Calendar. Please ensure you have a calendar account (like iCloud) set up in the Settings app.")
            }
        }
    }

    private func calculateSelectedDate() -> Date {
        let calendar = Calendar.current
        switch selectedTimeOption {
            case "Tonight at 7 PM":
                return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
            case "Tomorrow at 7 PM":
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow) ?? Date()
            case "This Weekend":
                let today = Date()
                let weekday = calendar.component(.weekday, from: today)
                let daysUntilSaturday = (7 - weekday + 7) % 7
                let daysToAdd = daysUntilSaturday == 0 ? 7 : daysUntilSaturday
                let saturday = calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
                return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: saturday) ?? Date()
            default:
                return selectedDate
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: calculateSelectedDate())
    }
}
