// EventKitService.swift - FIXED VERSION
// HeyKidsWatchThis - Phase 6.3: Calendar Integration Implementation
// iOS 17+ EventKit integration for Family Movie Scheduler functionality
// FIXED: All code properly structured within classes/structs

import Foundation
import EventKit
import os.log

// MARK: - Error Types
enum EventError: Error, LocalizedError {
    case permissionDenied
    case creationFailed(String)
    case updateFailed(String)
    case deletionFailed(String)
    case eventNotFound
    case invalidDate
    case calendarNotFound
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Calendar access permission denied"
        case .creationFailed(let message):
            return "Failed to create event: \(message)"
        case .updateFailed(let message):
            return "Failed to update event: \(message)"
        case .deletionFailed(let message):
            return "Failed to delete event: \(message)"
        case .eventNotFound:
            return "Event not found"
        case .invalidDate:
            return "Invalid date provided"
        case .calendarNotFound:
            return "Calendar not found"
        }
    }
}

// MARK: - Time Slot Suggestion
struct TimeSlotSuggestion {
    let startTime: Date
    let endTime: Date
    let movie: MovieData
    let appropriatenessScore: Double
    let reasoning: String
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

// MARK: - Age Constraints
struct AgeConstraints {
    let earliestStartTime: Int // Hour (24-hour format)
    let latestEndTime: Int     // Hour (24-hour format)
    let maxDuration: TimeInterval // Seconds
    let schoolNightRestriction: Bool
}

// MARK: - Day Type
enum DayType {
    case weeknight
    case weekend
    
    var description: String {
        switch self {
        case .weeknight: return "weeknight"
        case .weekend: return "weekend"
        }
    }
}

// MARK: - Recurrence Pattern
enum RecurrencePattern {
    case weekly
    case biweekly
    case monthly
    
    var description: String {
        switch self {
        case .weekly: return "weekly"
        case .biweekly: return "bi-weekly"
        case .monthly: return "monthly"
        }
    }
}

// MARK: - Movie Night Event
struct MovieNightEvent {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let notes: String?
    let isRecurring: Bool
    
    var movieTitle: String {
        // Extract movie title from event title
        let prefix = "🎬 Family Movie Night: "
        if title.hasPrefix(prefix) {
            return String(title.dropFirst(prefix.count))
        }
        return title
    }
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    var isUpcoming: Bool {
        startDate > Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(startDate) {
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: startDate))"
        } else if Calendar.current.isDateInTomorrow(startDate) {
            formatter.timeStyle = .short
            return "Tomorrow at \(formatter.string(from: startDate))"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: startDate)
        }
    }
    
    var timeUntilStart: String {
        let now = Date()
        let timeInterval = startDate.timeIntervalSince(now)
        
        if timeInterval < 0 {
            return "Started"
        }
        
        let hours = Int(timeInterval.rounded(.down)) / 3600
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600).rounded(.down)) / 60
        
        if hours > 24 {
            let days = hours / 24
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - EventKit Service Protocol
protocol EventKitServiceProtocol {
    func requestCalendarAccess() async -> Bool
    func scheduleMovieNight(for movie: MovieData, on date: Date, duration: TimeInterval?) async -> Result<String, EventError>
    func findOptimalTimeSlots(for movie: MovieData, on date: Date, familyAgeGroups: [AgeGroup]) -> [TimeSlotSuggestion]
    func createRecurringMovieNight(movie: MovieData, pattern: RecurrencePattern, startDate: Date) async -> Result<String, EventError>
    func getFamilyCalendars() async -> [EKCalendar]
    func updateMovieNightEvent(eventId: String, newDate: Date) async -> Result<Void, EventError>
    func deleteMovieNightEvent(eventId: String) async -> Result<Void, EventError>
    func getUpcomingMovieNights(limit: Int) async -> [MovieNightEvent]
}

// MARK: - EventKit Service Implementation
@available(iOS 17.0, *)
class EventKitService: EventKitServiceProtocol {
    
    // MARK: - Properties
    
    private let eventStore = EKEventStore()
    private let logger = Logger(subsystem: "com.heykidswatchthis.app", category: "EventKitService")
    
    // MARK: - Calendar Access
    
    func requestCalendarAccess() async -> Bool {
        do {
            // iOS 17+ write-only access for creating events
            let granted = try await eventStore.requestWriteOnlyAccessToEvents()
            logger.info("📅 Calendar access granted: \(granted)")
            return granted
        } catch {
            logger.error("📅 Calendar access failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Movie Night Scheduling
    
    func scheduleMovieNight(
        for movie: MovieData, 
        on date: Date, 
        duration: TimeInterval? = nil
    ) async -> Result<String, EventError> {
        
        logger.debug("📅 Scheduling movie night for '\(movie.title)' on \(date)")
        
        // Ensure calendar access
        guard await requestCalendarAccess() else {
            return .failure(.permissionDenied)
        }
        
        // FIXED: Calculate duration with explicit type annotation
        let movieDuration: TimeInterval = duration ?? calculateMovieDuration(for: movie)
        
        // Create the event
        let event = EKEvent(eventStore: eventStore)
        event.title = "🎬 Family Movie Night: \(movie.title)"
        event.startDate = date
        event.endDate = date.addingTimeInterval(movieDuration)
        event.location = "Living Room" // Default location
        
        // Enhanced event notes with movie details
        event.notes = buildMovieNightNotes(for: movie)
        
        // Set calendar (user's default or family calendar)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add pre-movie setup reminders
        addMovieNightReminders(to: event, for: movie)
        
        // Set availability (show as busy during movie night)
        event.availability = .busy
        
        do {
            try eventStore.save(event, span: .thisEvent)
            let eventId = event.eventIdentifier
            
            logger.info("📅 Successfully scheduled movie night: '\(movie.title)' (ID: \(eventId ?? "unknown"))")
            return .success(eventId ?? "")
        } catch {
            logger.error("📅 Failed to save movie night event: \(error.localizedDescription)")
            return .failure(.creationFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Smart Time Slot Suggestions
    
    func findOptimalTimeSlots(
        for movie: MovieData, 
        on date: Date, 
        familyAgeGroups: [AgeGroup]
    ) -> [TimeSlotSuggestion] {
        
        logger.debug("📅 Finding optimal time slots for '\(movie.title)' on \(date)")
        
        let movieDuration = calculateMovieDuration(for: movie)
        let ageConstraints = calculateAgeConstraints(for: familyAgeGroups)
        let dayType = determineDayType(for: date)
        
        var suggestions: [TimeSlotSuggestion] = []
        
        // Generate time slots based on age constraints and day type
        let possibleStartTimes = generatePossibleStartTimes(
            for: dayType, 
            ageConstraints: ageConstraints, 
            movieDuration: movieDuration
        )
        
        for startTime in possibleStartTimes {
            let endTime = startTime.addingTimeInterval(movieDuration)
            
            // Check if this time slot is appropriate
            if isTimeSlotAppropriate(
                startTime: startTime, 
                endTime: endTime, 
                movie: movie, 
                ageConstraints: ageConstraints, 
                dayType: dayType
            ) {
                let suggestion = TimeSlotSuggestion(
                    startTime: startTime,
                    endTime: endTime,
                    movie: movie,
                    appropriatenessScore: calculateAppropriatenessScore(
                        startTime: startTime, 
                        movie: movie, 
                        ageConstraints: ageConstraints, 
                        dayType: dayType
                    ),
                    reasoning: generateReasoning(
                        startTime: startTime, 
                        movie: movie, 
                        ageConstraints: ageConstraints, 
                        dayType: dayType
                    )
                )
                
                suggestions.append(suggestion)
            }
        }
        
        // Sort by appropriateness score (highest first)
        suggestions.sort { $0.appropriatenessScore > $1.appropriatenessScore }
        
        logger.info("📅 Generated \(suggestions.count) time slot suggestions for '\(movie.title)'")
        return Array(suggestions.prefix(5)) // Return top 5 suggestions
    }
    
    // MARK: - Recurring Movie Nights
    
    func createRecurringMovieNight(
        movie: MovieData, 
        pattern: RecurrencePattern, 
        startDate: Date
    ) async -> Result<String, EventError> {
        
        // FIXED: Break down complex string interpolation to help compiler
        let patternDescription: String = pattern.description
        logger.debug("📅 Creating recurring movie night for '\(movie.title)' with pattern: \(patternDescription)")
        
        guard await requestCalendarAccess() else {
            return .failure(.permissionDenied)
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "🎬 Weekly Family Movie Night: \(movie.title)"
        event.startDate = startDate
        
        // FIXED: Add explicit type annotation for duration calculation
        let movieDuration: TimeInterval = calculateMovieDuration(for: movie)
        event.endDate = startDate.addingTimeInterval(movieDuration)
        
        event.location = "Living Room"
        event.notes = buildRecurringMovieNightNotes(for: movie, pattern: pattern)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Set up recurrence rule
        let recurrenceRule = createRecurrenceRule(for: pattern)
        event.recurrenceRules = [recurrenceRule]
        
        // Add reminders
        addMovieNightReminders(to: event, for: movie)
        
        do {
            try eventStore.save(event, span: .futureEvents)
            let eventId = event.eventIdentifier
            
            logger.info("📅 Successfully created recurring movie night: '\(movie.title)' (ID: \(eventId ?? "unknown"))")
            return .success(eventId ?? "")
        } catch {
            logger.error("📅 Failed to create recurring movie night: \(error.localizedDescription)")
            return .failure(.creationFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Family Calendar Management
    
    func getFamilyCalendars() async -> [EKCalendar] {
        logger.debug("📅 Fetching family calendars")
        
        guard await requestCalendarAccess() else {
            logger.warning("📅 No calendar access, returning empty family calendars")
            return []
        }
        
        let allCalendars = eventStore.calendars(for: .event)
        
        // Filter for family/shared calendars
        let familyCalendars = allCalendars.filter { calendar in
            // Look for family-related keywords or shared calendars
            let title = calendar.title.lowercased()
            return title.contains("family") || 
                   title.contains("shared") || 
                   title.contains("home") ||
                   calendar.isSubscribed ||
                   calendar.allowsContentModifications
        }
        
        logger.info("📅 Found \(familyCalendars.count) family calendars out of \(allCalendars.count) total")
        return familyCalendars
    }
    
    // MARK: - Event Management
    
    func updateMovieNightEvent(eventId: String, newDate: Date) async -> Result<Void, EventError> {
        logger.debug("📅 Updating movie night event: \(eventId)")
        
        guard await requestCalendarAccess() else {
            return .failure(.permissionDenied)
        }
        
        guard let event = eventStore.event(withIdentifier: eventId) else {
            return .failure(.eventNotFound)
        }
        
        let duration = event.endDate.timeIntervalSince(event.startDate)
        event.startDate = newDate
        event.endDate = newDate.addingTimeInterval(duration)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            logger.info("📅 Successfully updated movie night event: \(eventId)")
            return .success(())
        } catch {
            logger.error("📅 Failed to update movie night event: \(error.localizedDescription)")
            return .failure(.updateFailed(error.localizedDescription))
        }
    }
    
    func deleteMovieNightEvent(eventId: String) async -> Result<Void, EventError> {
        logger.debug("📅 Deleting movie night event: \(eventId)")
        
        guard await requestCalendarAccess() else {
            return .failure(.permissionDenied)
        }
        
        guard let event = eventStore.event(withIdentifier: eventId) else {
            return .failure(.eventNotFound)
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            logger.info("📅 Successfully deleted movie night event: \(eventId)")
            return .success(())
        } catch {
            logger.error("📅 Failed to delete movie night event: \(error.localizedDescription)")
            return .failure(.deletionFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Upcoming Events
    
    func getUpcomingMovieNights(limit: Int = 10) async -> [MovieNightEvent] {
        logger.debug("📅 Fetching upcoming movie nights (limit: \(limit))")
        
        guard await requestCalendarAccess() else {
            logger.warning("📅 No calendar access, returning empty upcoming events")
            return []
        }
        
        let now = Date()
        // FIXED: Explicit type annotation to resolve ambiguity
        let oneMonthFromNow: Date = Calendar.current.date(byAdding: .month, value: 1, to: now) ?? now
        
        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: oneMonthFromNow,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        // Filter for movie night events
        let movieNightEvents = events.compactMap { event -> MovieNightEvent? in
            guard event.title.contains("🎬") || event.title.lowercased().contains("movie") else {
                return nil
            }
            
            return MovieNightEvent(
                id: event.eventIdentifier,
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                notes: event.notes,
                isRecurring: event.hasRecurrenceRules
            )
        }
        
        let sortedEvents = movieNightEvents
            .sorted { $0.startDate < $1.startDate }
            .prefix(limit)
        
        logger.info("📅 Found \(sortedEvents.count) upcoming movie nights")
        return Array(sortedEvents)
    }
    
    // MARK: - Private Helper Methods
    
    private func calculateMovieDuration(for movie: MovieData) -> TimeInterval {
        // Estimate duration based on movie type and age group
        let baseDuration: TimeInterval
        
        switch movie.ageGroup {
        case .preschoolers:
            baseDuration = TimeInterval(60 * 60) // 1 hour
        case .littleKids:
            baseDuration = TimeInterval(90 * 60) // 1.5 hours
        case .bigKids:
            baseDuration = TimeInterval(105 * 60) // 1 hour 45 minutes
        case .tweens:
            baseDuration = TimeInterval(120 * 60) // 2 hours
        }
        
        // Add buffer time for setup and discussion
        let bufferTime: TimeInterval = TimeInterval(30 * 60) // 30 minutes
        
        return baseDuration + bufferTime
    }
    
    private func buildMovieNightNotes(for movie: MovieData) -> String {
        var notes = """
        🎬 FAMILY MOVIE NIGHT
        
        Movie: \(movie.title) (\(movie.year))
        Age Group: \(movie.ageGroup)
        Genre: \(movie.genre)
        Rating: \(movie.rating.map { "\($0)/5.0 ⭐" } ?? "Not rated")
        
        Streaming: \(movie.streamingServices.joined(separator: ", "))
        
        """
        
        if let movieNotes = movie.notes {
            notes += """
            About: \(movieNotes)
            
            """
        }
        
        notes += """
        📝 MOVIE NIGHT CHECKLIST:
        □ Prepare snacks and drinks
        □ Set up comfortable seating
        □ Test streaming service/device
        □ Prepare discussion questions
        □ Have camera ready for family photos
        
        🎯 POST-MOVIE ACTIVITIES:
        • Family discussion about the movie
        • Rate the movie together (1-5 stars)
        • Take a family photo
        • Create a memory entry in HeyKidsWatchThis
        
        Created by HeyKidsWatchThis Family Movie Scheduler
        """
        
        return notes
    }
    
    private func buildRecurringMovieNightNotes(for movie: MovieData, pattern: RecurrencePattern) -> String {
        var notes = buildMovieNightNotes(for: movie)
        
        notes += """
        
        📅 RECURRING SCHEDULE:
        This is a \(pattern.description) movie night series.
        Each session will feature family-friendly movies.
        
        """
        
        return notes
    }
    
    private func addMovieNightReminders(to event: EKEvent, for movie: MovieData) {
        // 30 minutes before: Setup reminder
        let setupReminder = EKAlarm(relativeOffset: TimeInterval(-30 * 60))
        
        // 5 minutes before: Start reminder
        let startReminder = EKAlarm(relativeOffset: TimeInterval(-5 * 60))
        
        event.alarms = [setupReminder, startReminder]
    }
    
    private func calculateAgeConstraints(for ageGroups: [AgeGroup]) -> AgeConstraints {
        // Find the most restrictive age constraints for the family
        let youngestGroup = ageGroups.min() ?? .tweens
        
        switch youngestGroup {
        case .preschoolers:
            return AgeConstraints(
                earliestStartTime: 16, // 4 PM
                latestEndTime: 19,    // 7 PM
                maxDuration: TimeInterval(90 * 60), // 1.5 hours
                schoolNightRestriction: true
            )
        case .littleKids:
            return AgeConstraints(
                earliestStartTime: 16, // 4 PM
                latestEndTime: 20,    // 8 PM
                maxDuration: TimeInterval(120 * 60), // 2 hours
                schoolNightRestriction: true
            )
        case .bigKids:
            return AgeConstraints(
                earliestStartTime: 15, // 3 PM
                latestEndTime: 21,    // 9 PM
                maxDuration: TimeInterval(150 * 60), // 2.5 hours
                schoolNightRestriction: false
            )
        case .tweens:
            return AgeConstraints(
                earliestStartTime: 14, // 2 PM
                latestEndTime: 22,    // 10 PM
                maxDuration: TimeInterval(180 * 60), // 3 hours
                schoolNightRestriction: false
            )
        }
    }
    
    private func determineDayType(for date: Date) -> DayType {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Sunday = 1, Monday = 2, ..., Saturday = 7
        if weekday == 1 || weekday == 7 { // Sunday or Saturday
            return .weekend
        } else {
            return .weeknight
        }
    }
    
    private func generatePossibleStartTimes(
        for dayType: DayType,
        ageConstraints: AgeConstraints,
        movieDuration: TimeInterval
    ) -> [Date] {
        
        let calendar = Calendar.current
        let today = Date()
        
        var startTimes: [Date] = []
        let startHour = ageConstraints.earliestStartTime
        let endHour = ageConstraints.latestEndTime
        
        // Generate hourly slots within constraints
        for hour in startHour..<endHour {
            if let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                let endTime = startTime.addingTimeInterval(movieDuration)
                let endHourFromTime = calendar.component(.hour, from: endTime)
                
                // Ensure movie ends before latest allowed time
                if endHourFromTime <= ageConstraints.latestEndTime {
                    startTimes.append(startTime)
                }
            }
        }
        
        return startTimes
    }
    
    private func isTimeSlotAppropriate(
        startTime: Date,
        endTime: Date,
        movie: MovieData,
        ageConstraints: AgeConstraints,
        dayType: DayType
    ) -> Bool {
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        
        // Check time constraints
        guard startHour >= ageConstraints.earliestStartTime else { return false }
        guard endHour <= ageConstraints.latestEndTime else { return false }
        
        // Check duration constraints
        let duration = endTime.timeIntervalSince(startTime)
        guard duration <= ageConstraints.maxDuration else { return false }
        
        // Check school night restrictions
        if ageConstraints.schoolNightRestriction && dayType == .weeknight {
            // More restrictive times for school nights
            guard startHour >= 18 else { return false } // After 6 PM
            guard endHour <= 20 else { return false }   // Before 8 PM
        }
        
        return true
    }
    
    // FIXED: Simplified complex switch expression that was causing compiler timeout
    private func calculateAppropriatenessScore(
        startTime: Date,
        movie: MovieData,
        ageConstraints: AgeConstraints,
        dayType: DayType
    ) -> Double {
        
        var score: Double = 100.0
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        
        // FIXED: Break down complex switch expression into simpler if-else
        let optimalStartTime: Int
        
        if movie.ageGroup == .preschoolers {
            optimalStartTime = dayType == .weekend ? 16 : 17
        } else if movie.ageGroup == .littleKids {
            optimalStartTime = dayType == .weekend ? 15 : 18
        } else if movie.ageGroup == .bigKids {
            optimalStartTime = dayType == .weekend ? 14 : 19
        } else { // tweens
            optimalStartTime = dayType == .weekend ? 14 : 19
        }
        
        // Reduce score based on distance from optimal time
        let timeDifference = abs(startHour - optimalStartTime)
        score -= Double(timeDifference) * 10.0
        
        // Bonus for weekend availability
        if dayType == .weekend {
            score += 20.0
        }
        
        // Bonus for age-appropriate content
        score += 10.0
        
        return max(score, 0.0)
    }
    
    private func generateReasoning(
        startTime: Date,
        movie: MovieData,
        ageConstraints: AgeConstraints,
        dayType: DayType
    ) -> String {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let endTime = startTime.addingTimeInterval(calculateMovieDuration(for: movie))
        
        var reasoning = "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
        
        if dayType == .weekend {
            reasoning += " • Perfect for weekend family time"
        } else {
            reasoning += " • Good for \(dayType.description) schedule"
        }
        
        if startHour >= 18 {
            reasoning += " • After dinner timing"
        } else if startHour >= 15 {
            reasoning += " • Afternoon relaxation time"
        }
        
        reasoning += " • Age-appropriate for \(movie.ageGroup)"
        
        return reasoning
    }
    
    private func createRecurrenceRule(for pattern: RecurrencePattern) -> EKRecurrenceRule {
        switch pattern {
        case .weekly:
            return EKRecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                end: nil
            )
        case .biweekly:
            return EKRecurrenceRule(
                recurrenceWith: .weekly,
                interval: 2,
                end: nil
            )
        case .monthly:
            return EKRecurrenceRule(
                recurrenceWith: .monthly,
                interval: 1,
                end: nil
            )
        }
    }
}

// MARK: - Mock Implementation for Testing
class MockEventKitService: EventKitServiceProtocol {
    var shouldGrantAccess = true
    var shouldSucceedScheduling = true
    
    func requestCalendarAccess() async -> Bool {
        return shouldGrantAccess
    }
    
    func scheduleMovieNight(for movie: MovieData, on date: Date, duration: TimeInterval?) async -> Result<String, EventError> {
        if shouldSucceedScheduling {
            return .success("mock-event-id-\(UUID().uuidString)")
        } else {
            return .failure(.creationFailed("Mock failure"))
        }
    }
    
    func findOptimalTimeSlots(for movie: MovieData, on date: Date, familyAgeGroups: [AgeGroup]) -> [TimeSlotSuggestion] {
        // Return mock suggestions for testing
        let now = Date()
        
        // FIXED: Break down complex time calculations
        let tomorrowInterval: TimeInterval = TimeInterval(24 * 60 * 60)
        let twoHoursInterval: TimeInterval = TimeInterval(2 * 60 * 60)
        
        let startTime = now.addingTimeInterval(tomorrowInterval)
        let endTime = now.addingTimeInterval(tomorrowInterval + twoHoursInterval)
        
        return [
            TimeSlotSuggestion(
                startTime: startTime,
                endTime: endTime,
                movie: movie,
                appropriatenessScore: 90.0,
                reasoning: "Perfect time for \(movie.ageGroup) movie night"
            )
        ]
    }
    
    func createRecurringMovieNight(movie: MovieData, pattern: RecurrencePattern, startDate: Date) async -> Result<String, EventError> {
        return .success("mock-recurring-event-id")
    }
    
    func getFamilyCalendars() async -> [EKCalendar] {
        return [] // Mock empty for testing
    }
    
    func updateMovieNightEvent(eventId: String, newDate: Date) async -> Result<Void, EventError> {
        return .success(())
    }
    
    func deleteMovieNightEvent(eventId: String) async -> Result<Void, EventError> {
        return .success(())
    }
    
    func getUpcomingMovieNights(limit: Int) async -> [MovieNightEvent] {
        return [] // Mock empty for testing
    }
}

// MARK: - Extensions moved to AgeGroup.swift to avoid duplicate conformance
