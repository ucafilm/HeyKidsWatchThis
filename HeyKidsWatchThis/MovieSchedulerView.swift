// MovieSchedulerView.swift
// FINAL DEFINITIVE VERSION
// This is the single, correct scheduler view for the entire app.

import SwiftUI

struct MovieSchedulerView: View {
    let movie: MovieData
    let movieService: MovieServiceProtocol
    let onDismiss: () -> Void
    
    // Connect to the shared CalendarService from the environment
    @EnvironmentObject private var calendarService: CalendarService
    
    @State private var selectedDate = Date()
    @State private var isScheduling = false
    @State private var alertType: SchedulerAlertType?
    @State private var selectedTimeOption = "Tonight at 7 PM"

    private let timeOptions = ["Tonight at 7 PM", "Tomorrow at 7 PM", "This Weekend", "Custom Date..."]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Movie Header
                    VStack(spacing: 12) {
                        Text(movie.emoji).font(.system(size: 60))
                        Text(movie.title).font(.title2).bold().multilineTextAlignment(.center)
                        Text("\(movie.ageGroup.description) • \(movie.genre)").font(.caption).foregroundStyle(.secondary)
                    }.padding().background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                    // Time Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("When would you like to watch?").font(.headline)
                        ForEach(timeOptions, id: \.self) { option in
                            Button(action: { selectedTimeOption = option }) {
                                HStack {
                                    Text(option).foregroundStyle(.primary)
                                    Spacer()
                                    if selectedTimeOption == option { Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue) }
                                }
                            }.padding().background(RoundedRectangle(cornerRadius: 8).fill(selectedTimeOption == option ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground)))
                        }
                    }.padding().background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    // Custom Date Picker (using the stable .compact style)
                    if selectedTimeOption == "Custom Date..." {
                        DatePicker(
                            "Select Date & Time",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Schedule Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: onDismiss) }
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Done") { scheduleMovie() }.disabled(isScheduling)
                }
            }
            // Alert for success or failure feedback
            .alert(item: $alertType) { type in
                switch type {
                case .success(let message):
                    return Alert(title: Text("Movie Scheduled!"), message: Text(message), dismissButton: .default(Text("Great!"), action: onDismiss))
                case .failure(let message):
                    return Alert(title: Text("Scheduling Failed"), message: Text(message), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    // This function now correctly calls the CalendarService
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
                alertType = .failure("The movie was saved in the app, but could not be added to your iOS Calendar. Please make sure you have a calendar account (like iCloud) set up in the Settings app.")
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
