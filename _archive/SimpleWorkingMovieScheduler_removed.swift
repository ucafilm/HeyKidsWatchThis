// SimpleWorkingMovieScheduler.swift
// EMERGENCY FIX: Thread-safe scheduler without EventKit complications
// Fixes white screen issue by removing problematic calendar integration

import SwiftUI
import Foundation

struct SimpleWorkingMovieScheduler: View {
    let movie: MovieData
    let movieService: MovieServiceProtocol // FIXED: Use protocol not concrete class
    let onDismiss: () -> Void
    
    @State private var selectedTimeOption = "Tonight at 7 PM"
    @State private var selectedDate = Date()
    @State private var isScheduling = false
    @State private var showSuccess = false
    
    private let timeOptions = [
        "Tonight at 7 PM",
        "Tomorrow at 7 PM", 
        "This Weekend",
        "Custom Date..."
    ]
    
    var body: some View {
        // Use simple VStack instead of NavigationView to avoid threading issues
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    onDismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Schedule Movie")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    scheduleMovie()
                }
                .foregroundColor(.blue)
                .disabled(isScheduling)
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Movie Header
                    VStack(spacing: 16) {
                        Text(movie.emoji)
                            .font(.system(size: 60))
                        
                        Text(movie.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(movie.ageGroup.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Time Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("When would you like to watch?")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(timeOptions, id: \.self) { option in
                                Button {
                                    selectedTimeOption = option
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
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedTimeOption == option ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Custom Date Picker
                    if selectedTimeOption == "Custom Date..." {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Date & Time")
                                .font(.headline)
                            
                            DatePicker(
                                "Movie Night",
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
                        .transition(.opacity)
                    }
                    
                    // Schedule Button
                    Button {
                        scheduleMovie()
                    } label: {
                        HStack {
                            if isScheduling {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
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
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            print("🎬 ✅ SimpleWorkingMovieScheduler appeared for: \(movie.title)")
        }
        .alert("Movie Scheduled!", isPresented: $showSuccess) {
            Button("Great!") {
                onDismiss()
            }
        } message: {
            Text("\(movie.title) has been scheduled for \(formatSelectedDate())")
        }
    }
    
    // MARK: - Actions (Thread-Safe)
    
    private func scheduleMovie() {
        print("🎬 Starting simple movie scheduling for \(movie.title)")
        isScheduling = true
        
        let scheduledDate = calculateSelectedDate()
        
        // SIMPLE: Only schedule in app (no EventKit threading issues)
        DispatchQueue.main.async {
            movieService.scheduleMovie(movie.id, for: scheduledDate)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isScheduling = false
                showSuccess = true
                
                print("🎬 ✅ Simple scheduling success for \(movie.title)")
                print("🎬 📅 Scheduled for: \(scheduledDate)")
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
    SimpleWorkingMovieScheduler(
        movie: MovieData(
            title: "The Iron Giant",
            year: 1999,
            ageGroup: .bigKids,
            genre: "Animation",
            emoji: "🤖",
            streamingServices: ["HBO Max"]
        ),
        movieService: MovieService(dataProvider: MovieDataProvider()),
        onDismiss: {}
    )
}

/*
EMERGENCY FIXES APPLIED:

🚨 THREAD-SAFETY:
✅ Removed EventKit (causes pthread issues)
✅ Removed NavigationView/NavigationStack (threading conflicts)
✅ Used simple VStack structure
✅ All operations on main thread

🚨 RENDERING FIXES:
✅ Simple backgrounds (no complex materials)
✅ Basic color scheme
✅ Minimal view hierarchy
✅ No async calendar operations

🚨 WHAT THIS PROVIDES:
✅ Working movie scheduler (no white screen)
✅ Time selection (Tonight, Tomorrow, Weekend, Custom)
✅ App-based scheduling (persists in watchlist)
✅ Success feedback
✅ Clean, simple interface

🚨 WHAT'S MISSING:
❌ iOS Calendar integration (will add back later)
❌ Complex animations
❌ Advanced navigation patterns

GOAL: Get basic scheduling working first, then add calendar later
*/