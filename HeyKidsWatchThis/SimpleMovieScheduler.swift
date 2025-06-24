// SimpleMovieScheduler.swift - Minimal working scheduler to fix white screen
// This replaces the complex MovieSchedulerView temporarily

import SwiftUI

struct SimpleMovieScheduler: View {
    let movie: MovieData
    let movieService: MovieService
    let onDismiss: () -> Void
    
    @State private var selectedTime = "Tonight at 7 PM"
    
    private let timeOptions = [
        "Tonight at 7 PM",
        "Tomorrow at 7 PM", 
        "This Weekend",
        "Next Week"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Movie Header
                VStack(spacing: 16) {
                    Text(movie.emoji)
                        .font(.system(size: 80))
                    
                    Text("Schedule \(movie.title)")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("When would you like to watch this movie?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Simple time picker
                VStack(spacing: 12) {
                    ForEach(timeOptions, id: \.self) { option in
                        Button(action: {
                            selectedTime = option
                            scheduleMovie(for: option)
                        }) {
                            HStack {
                                Text(option)
                                    .font(.headline)
                                Spacer()
                                if selectedTime == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTime == option ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Bottom buttons
                VStack(spacing: 16) {
                    Button("Schedule Movie Night") {
                        scheduleMovie(for: selectedTime)
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                    
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Schedule Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            print("🎬 SimpleMovieScheduler appeared for: \(movie.title)")
        }
    }
    
    private func scheduleMovie(for timeOption: String) {
        print("🎬 Scheduling \(movie.title) for: \(timeOption)")
        
        // Calculate actual date based on option
        let scheduledDate: Date
        switch timeOption {
        case "Tonight at 7 PM":
            scheduledDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
        case "Tomorrow at 7 PM":
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            scheduledDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow) ?? Date()
        case "This Weekend":
            let weekend = Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date()
            scheduledDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: weekend) ?? Date()
        case "Next Week":
            let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            scheduledDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: nextWeek) ?? Date()
        default:
            scheduledDate = Date()
        }
        
        // Schedule the movie
        movieService.scheduleMovie(movie.id, for: scheduledDate)
        
        print("🎬 ✅ Movie scheduled successfully for \(scheduledDate)")
        
        // Show success feedback
        HapticFeedbackManager.shared.triggerSuccess()
        
        // Dismiss after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onDismiss()
        }
    }
}

#Preview {
    SimpleMovieScheduler(
        movie: MovieData(
            title: "Test Movie",
            year: 2024,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🎬",
            streamingServices: ["Disney+"]
        ),
        movieService: MovieService(dataProvider: MovieDataProvider()),
        onDismiss: {}
    )
}
