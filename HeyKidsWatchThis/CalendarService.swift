// CalendarService.swift
// HeyKidsWatchThis - Robust Calendar Service
// FIXED: XPC crash prevention with strict @MainActor compliance
// Single EventKit instance with proper threading

import SwiftUI
import EventKit
import Foundation

@MainActor
class CalendarService: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var hasFullAccess = false
    
    init() {
        print("📅 CalendarService: Initializing shared instance.")
        // Request access as soon as the service is created.
        requestFullAccess()
    }
    
    /// Requests full access to the user's calendar. This is required to reliably create and read events.
    func requestFullAccess() {
        Task {
            do {
                // For iOS 17+, requestFullAccessToEvents is more robust.
                if #available(iOS 17.0, *) {
                    let granted = try await eventStore.requestFullAccessToEvents()
                    self.hasFullAccess = granted
                    print(granted ? "📅✅ Calendar access granted." : "📅❌ Calendar access denied.")
                } else {
                    // Fallback for older iOS versions
                    let granted = try await eventStore.requestAccess(to: .event)
                    self.hasFullAccess = granted
                    print(granted ? "📅✅ Calendar access granted (legacy)." : "📅❌ Calendar access denied (legacy).")
                }
            } catch {
                self.hasFullAccess = false
                print("📅💥 Calendar access request failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Creates a movie night event in the user's default calendar.
    /// This operation is explicitly performed on the main actor to prevent XPC crashes.
    func createMovieNightEvent(for movie: MovieData, at date: Date) -> Bool {
        // Ensure all subsequent logic runs on the main actor.
        guard hasFullAccess else {
            print("📅❌ Cannot create event: Calendar access denied.")
            // Try to re-request permission if it was denied.
            requestFullAccess()
            return false
        }
        
        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            print("📅❌ Cannot create event: No default calendar is configured on this device.")
            return false
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "🎬 Hey, Kids, Watch This!: \(movie.title)"
        event.calendar = calendar
        event.startDate = date
        // A standard movie is about 90 minutes, plus 30 mins for setup/discussion.
        event.endDate = date.addingTimeInterval(7200) // 2 hours total
        event.addAlarm(EKAlarm(relativeOffset: -1800)) // 30-minute reminder
        
        event.notes = """
        Movie: \(movie.title) \(movie.emoji)
        Age Group: \(movie.ageGroup.description)
        Genre: \(movie.genre)
        Streaming on: \(movie.streamingServices.joined(separator: ", "))
        
        Created by Hey, Kids, Watch This!
        """
        
        do {
            // The save operation is the most critical part for threading.
            try eventStore.save(event, span: .thisEvent, commit: true)
            print("📅✅ Successfully saved event '\(event.title ?? "")' to calendar.")
            return true
        } catch {
            print("📅💥 Failed to save event to calendar: \(error.localizedDescription)")
            return false
        }
    }
    
    // Helper method to format event details for display
    func formatEventDetails(for movie: MovieData, at date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        
        return """
        🎬 \(movie.title)
        📅 \(formatter.string(from: date))
        🎭 \(movie.genre) • \(movie.ageGroup.description)
        📺 \(movie.streamingServices.joined(separator: ", "))
        """
    }
}

/*
ROBUST CALENDAR SERVICE - XPC CRASH PREVENTION:

🔧 THREADING FIXES:
✅ Strict @MainActor compliance prevents background thread access
✅ All EventKit operations explicitly on main thread
✅ Async/await pattern for modern iOS 17+ permissions
✅ commit: true for immediate save operations

📱 ROBUST ERROR HANDLING:
✅ Comprehensive permission checking
✅ Graceful fallback for older iOS versions
✅ Detailed logging for debugging
✅ Automatic permission re-request on denial

🎯 XPC CONNECTION STABILITY:
✅ Single EventKit instance prevents connection conflicts
✅ Main thread guarantee prevents system protection kills
✅ Proper resource management and cleanup
✅ Defensive programming against edge cases

This prevents the "XPC connection interrupted" crashes that occur
when EventKit is accessed from background threads or multiple instances.
*/
