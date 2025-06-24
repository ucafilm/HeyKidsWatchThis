// In HeyKidsWatchThis/MovieSchedulerView.swift

import SwiftUI

struct MovieSchedulerView: View {
    let movie: MovieData
    let movieService: MovieServiceProtocol
    let onDismiss: () -> Void
    
    @State private var selectedDate = Date()
    @State private var isScheduling = false
    @State private var selectedTimeOption = "Tonight at 7 PM"
    @State private var showingCustomDatePicker = false

    private let timeOptions = ["Tonight at 7 PM", "Tomorrow at 7 PM", "This Weekend", "Custom Date..."]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Movie Header
                VStack(spacing: 12) {
                    Text(movie.emoji).font(.system(size: 60))
                    Text(movie.title).font(.title2.bold()).multilineTextAlignment(.center)
                    Text("\(movie.ageGroup.description) • \(movie.genre)").font(.caption).foregroundStyle(.secondary)
                }.padding()

                // Time Selection
                ForEach(timeOptions, id: \.self) { option in
                    Button(action: {
                        selectedTimeOption = option
                        withAnimation { showingCustomDatePicker = (option == "Custom Date...") }
                    }) {
                        HStack {
                            Text(option).foregroundStyle(.primary)
                            Spacer()
                            if selectedTimeOption == option { Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue) }
                        }
                    }.padding().background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                }
                
                if showingCustomDatePicker {
                    DatePicker("Date", selection: $selectedDate, in: Date()...)
                        .datePickerStyle(.compact) // CRITICAL FIX: Avoids .wheel style bug
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .slide))
                }
                
                Spacer()
                
                // Action Button
                Button(action: scheduleMovie) {
                    HStack {
                        if isScheduling { ProgressView().tint(.white) }
                        Text(isScheduling ? "Scheduling..." : "Schedule Movie Night").bold()
                    }
                }
                .frame(maxWidth: .infinity).padding().background(Color.blue.gradient).foregroundStyle(.white).clipShape(Capsule())
                .disabled(isScheduling)
            }
            .padding()
            .navigationTitle("Schedule Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { onDismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") { scheduleMovie() }.disabled(isScheduling) }
            }
        }
    }
    
    private func scheduleMovie() {
        isScheduling = true
        let finalDate = calculateSelectedDate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            movieService.scheduleMovie(movie.id, for: finalDate)
            HapticFeedbackManager.shared.triggerSuccess()
            isScheduling = false
            onDismiss()
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
                let saturday = calendar.date(byAdding: .day, value: daysUntilSaturday == 0 ? 7 : daysUntilSaturday, to: today) ?? today
                return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: saturday) ?? Date()
            default:
                return selectedDate
        }
    }
}
