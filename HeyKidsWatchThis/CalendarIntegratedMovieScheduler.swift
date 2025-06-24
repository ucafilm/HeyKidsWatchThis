// CalendarIntegratedMovieScheduler.swift
// TDD + RAG + Context7: Working iOS Calendar Integration
// FIXED: Uses shared CalendarService to prevent XPC connection issues

import SwiftUI
import EventKit
import Foundation

// MARK: - Working Movie Scheduler View
struct CalendarIntegratedMovieScheduler: View {
    let movie: MovieData
    let movieService: MovieServiceProtocol // FIXED: Use protocol not concrete class
    let onDismiss: () -> Void
    
    @EnvironmentObject private var calendarService: CalendarService // USE SHARED SERVICE
    @State private var selectedDate = Date()
    @State private var isScheduling = false
    @State private var showSuccess = false
    @State private var selectedTimeOption = "Tonight at 7 PM"
    
    private let timeOptions = [
        "Tonight at 7 PM",
        "Tomorrow at 7 PM", 
        "This Weekend",
        "Custom Date..."
    ]
    
    var body: some View {
        NavigationView { // Use NavigationView for better compatibility
            ZStack {
                // Simple background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Movie Header
                    VStack(spacing: 12) {
                        Text(movie.emoji)
                            .font(.system(size: 50))
                        
                        Text(movie.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(movie.ageGroup.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Time Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("When would you like to watch?")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(timeOptions, id: \.self) { option in
                            Button {
                                selectedTimeOption = option
                                if option == "Custom Date..." {
                                    // Show date picker
                                }
                            } label: {
                                HStack {
                                    Text(option)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedTimeOption == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedTimeOption == option ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Custom Date Picker
                    if selectedTimeOption == "Custom Date..." {
                        VStack {
                            DatePicker(
                                "Select Date & Time",
                                selection: $selectedDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Schedule Button
                        Button {
                            scheduleMovieNight()
                        } label: {
                            HStack {
                                if isScheduling {
                                    ProgressView()
                                        .scaleEffect(0.8)
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
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.blue)
                            )
                        }
                        .disabled(isScheduling)
                        
                        // Calendar Permission Status
                        if !calendarService.hasCalendarAccess {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Calendar access needed for reminders")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Schedule Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
            .alert("Movie Scheduled!", isPresented: $showSuccess) {
                Button("OK") {
                    onDismiss()
                }
            } message: {
                Text("\(movie.title) has been scheduled for \(formatSelectedDate())")
            }
        }
        .onAppear {
            print("🎬 ✅ CalendarIntegratedMovieScheduler appeared for: \(movie.title)")
        }
    }
    
    // MARK: - Actions
    
    private func scheduleMovieNight() {
        print("🎬 Starting movie scheduling for \(movie.title)")
        isScheduling = true
        
        let scheduledDate = calculateSelectedDate()
        
        // Schedule in app
        movieService.scheduleMovie(movie.id, for: scheduledDate)
        
        // Try to create calendar event
        let calendarSuccess = calendarService.createMovieNightEvent(for: movie, at: scheduledDate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isScheduling = false
            
            if calendarSuccess {
                print("🎬 ✅ Full scheduling success (app + calendar)")
            } else {
                print("🎬 ⚠️ App scheduled, calendar failed")
            }
            
            HapticFeedbackManager.shared.triggerSuccess()
            showSuccess = true
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
            let daysUntilSaturday = (7 - weekday + 1) % 7
            let saturday = calendar.date(byAdding: .day, value: daysUntilSaturday == 0 ? 7 : daysUntilSaturday, to: today) ?? today
            return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: saturday) ?? Date()
            
        case "Custom Date...":
            return selectedDate
            
        default:
            return Date()
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: calculateSelectedDate())
    }
}

// MARK: - Preview
#Preview {
    CalendarIntegratedMovieScheduler(
        movie: MovieData(
            title: "Finding Nemo",
            year: 2003,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🐠",
            streamingServices: ["Disney+"]
        ),
        movieService: MovieService(dataProvider: MovieDataProvider()),
        onDismiss: {}
    )
}

/*
WHAT YOU SHOULD SEE:

📱 A working scheduler interface with:
✅ Movie details (Finding Nemo 🐠)
✅ Time options (Tonight, Tomorrow, Weekend, Custom)
✅ Date picker for custom times
✅ "Schedule Movie Night" button
✅ Calendar permission status

📅 iOS Calendar Integration:
✅ Creates calendar event: "🎬 Family Movie Night: Finding Nemo"
✅ 2-hour duration
✅ 30-minute reminder
✅ Movie details in notes
✅ Uses default calendar

🔧 TDD + RAG + Context7 Fixes Applied:
✅ NavigationView for compatibility
✅ Simple backgrounds (no gradients)
✅ Proper EventKit integration
✅ Calendar permissions handling
✅ Error handling and feedback
*/