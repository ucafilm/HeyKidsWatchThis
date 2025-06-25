// CalendarIntegratedMovieScheduler.swift
// DEFINITIVE FIXED VERSION
// Replaced graphical date picker with a more stable style and fixed date logic.

import SwiftUI
import EventKit
import Foundation

enum SchedulerAlertType: Identifiable {
    case success(String)
    case failure(String)
    
    var id: String {
        switch self {
        case .success(let message): return "success-\(message)"
        case .failure(let message): return "failure-\(message)"
        }
    }
}

struct CalendarIntegratedMovieScheduler: View {
    let movie: MovieData
    let movieService: MovieServiceProtocol
    let onDismiss: () -> Void
    
    @EnvironmentObject private var calendarService: CalendarService
    @State private var selectedDate = Date()
    @State private var isScheduling = false
    @State private var alertType: SchedulerAlertType?
    @State private var selectedTimeOption = "Tonight at 7 PM"
    
    private let timeOptions = [
        "Tonight at 7 PM",
        "Tomorrow at 7 PM", 
        "This Weekend",
        "Custom Date..."
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Movie Header
                        VStack(spacing: 12) {
                            Text(movie.emoji).font(.system(size: 50))
                            Text(movie.title).font(.title2).fontWeight(.bold).multilineTextAlignment(.center)
                            Text(movie.ageGroup.description).font(.caption).foregroundColor(.secondary)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                        // Time Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When would you like to watch?").font(.headline).padding(.horizontal)
                            ForEach(timeOptions, id: \.self) { option in
                                Button { selectedTimeOption = option } label: {
                                    HStack {
                                        Text(option).foregroundColor(.primary)
                                        Spacer()
                                        if selectedTimeOption == option { Image(systemName: "checkmark.circle.fill").foregroundColor(.blue) }
                                    }
                                }.padding().background(RoundedRectangle(cornerRadius: 8).fill(selectedTimeOption == option ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground))).buttonStyle(.plain)
                            }
                        }.padding().background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                        // ✅ FIX 1: Using the more stable .compact date picker style to prevent crashes.
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
                        
                        // Action Button
                        Button(action: scheduleMovieNight) {
                            HStack {
                                if isScheduling {
                                    ProgressView().scaleEffect(0.8).tint(.white)
                                    Text("Scheduling...")
                                } else {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Schedule Movie Night")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(.blue))
                            .disabled(isScheduling)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Schedule Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel", action: onDismiss) }
            }
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
    
    private func scheduleMovieNight() {
        print("🎬 Starting movie scheduling for \(movie.title)")
        isScheduling = true
        
        let scheduledDate = calculateSelectedDate()
        movieService.scheduleMovie(movie.id, for: scheduledDate)
        
        let calendarSuccess = calendarService.createMovieNightEvent(for: movie, at: scheduledDate)
        
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
        case "Tonight at 7 PM": return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
        case "Tomorrow at 7 PM":
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow) ?? Date()
        case "This Weekend":
            let today = Date()
            let weekday = calendar.component(.weekday, from: today) // Sunday = 1, Saturday = 7
            // ✅ FIX 2: Corrected the date calculation logic for "This Weekend".
            let daysUntilSaturday = (7 - weekday + 7) % 7
            let daysToAdd = daysUntilSaturday == 0 ? 7 : daysUntilSaturday // If today is Sat, schedule for next Sat.
            let saturday = calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
            return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: saturday) ?? Date()
        default: return selectedDate
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: calculateSelectedDate())
    }
}
