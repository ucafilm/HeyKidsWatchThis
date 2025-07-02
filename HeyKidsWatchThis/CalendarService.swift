// CalendarService.swift
// HeyKidsWatchThis - Robust Calendar Service
// FIXED: Now handles cases where no default calendar is set.

import SwiftUI
import EventKit
import Foundation

@MainActor
class CalendarService: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var hasFullAccess = false
    
    init() {
        print("📅 CalendarService: Initializing shared instance.")
        requestFullAccess()
    }
    
    func requestFullAccess() {
        Task {
            do {
                if #available(iOS 17.0, *) {
                    let granted = try await eventStore.requestFullAccessToEvents()
                    self.hasFullAccess = granted
                    print(granted ? "📅✅ Calendar access granted." : "📅❌ Calendar access denied.")
                } else {
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
    
    func createMovieNightEvent(for movie: MovieData, at date: Date) -> Bool {
        guard hasFullAccess else {
            print("📅❌ Cannot create event: Calendar access denied.")
            requestFullAccess()
            return false
        }
        
        // ✅ FIX: If no default calendar is found, find the first available calendar we can write to.
        let targetCalendar: EKCalendar?
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            targetCalendar = defaultCalendar
        } else {
            // Find the first calendar that allows modification.
            targetCalendar = eventStore.calendars(for: .event).first { $0.allowsContentModifications }
        }

        guard let calendar = targetCalendar else {
            print("📅❌ Cannot create event: No default or writable calendar is configured on this device.")
            return false
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "🎬 Hey, Kids, Watch This!: \(movie.title)"
        event.calendar = calendar
        event.startDate = date
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
            try eventStore.save(event, span: .thisEvent, commit: true)
            print("📅✅ Successfully saved event '\(event.title ?? "")' to calendar '\(calendar.title)'.")
            return true
        } catch {
            print("📅💥 Failed to save event to calendar: \(error.localizedDescription)")
            return false
        }
    }
    
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
