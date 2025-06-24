// MockMovieService.swift
// HeyKidsWatchThis - TEST TARGET ONLY
// Mock implementation of MovieServiceProtocol for TESTING ONLY
// ⚠️ WARNING: This should NEVER be used in production code
// ✅ USAGE: Test targets only - for unit tests, UI tests, and test previews

import Foundation
import Observation
@testable import HeyKidsWatchThis

@Observable
class MockMovieService: MovieServiceProtocol {
    private var movies: [MovieData] = []
    private var _watchlist: [UUID] = []
    private var _watchedMovies: [UUID: Date] = [:]
    
    init() {
        setupSampleMovies()
    }
    
    // MARK: - MovieServiceProtocol Implementation
    
    func getAllMovies() -> [MovieData] {
        return movies.map { movie in
            MovieData(
                id: movie.id,
                title: movie.title,
                year: movie.year,
                ageGroup: movie.ageGroup,
                genre: movie.genre,
                emoji: movie.emoji,
                streamingServices: movie.streamingServices,
                rating: movie.rating,
                notes: movie.notes,
                isInWatchlist: isInWatchlist(movie.id),
                isWatched: isWatched(movie.id)
            )
        }
    }
    
    func getMovies(for ageGroup: AgeGroup) -> [MovieData] {
        return getAllMovies().filter { $0.ageGroup == ageGroup }
    }
    
    func searchMovies(_ query: String) -> [MovieData] {
        guard !query.isEmpty else { return getAllMovies() }
        
        let lowercaseQuery = query.lowercased()
        return getAllMovies().filter { movie in
            movie.title.lowercased().contains(lowercaseQuery) ||
            movie.genre.lowercased().contains(lowercaseQuery) ||
            movie.notes?.lowercased().contains(lowercaseQuery) == true
        }
    }
    
    func getMovie(by id: UUID) -> MovieData? {
        return getAllMovies().first { $0.id == id }
    }
    
    // MARK: - Watchlist Operations
    
    var watchlist: [UUID] {
        return _watchlist
    }
    
    func addToWatchlist(_ movieId: UUID) {
        guard !_watchlist.contains(movieId) else { return }
        _watchlist.append(movieId)
    }
    
    func removeFromWatchlist(_ movieId: UUID) {
        _watchlist.removeAll { $0 == movieId }
    }
    
    func isInWatchlist(_ movieId: UUID) -> Bool {
        return _watchlist.contains(movieId)
    }
    
    func getWatchlistMovies() -> [MovieData] {
        return getAllMovies().filter { _watchlist.contains($0.id) }
    }
    
    // MARK: - Watched Movies Tracking
    
    func markAsWatched(_ movieId: UUID) {
        markAsWatched(movieId, date: Date())
    }
    
    func markAsWatched(_ movieId: UUID, date: Date) {
        _watchedMovies[movieId] = date
    }
    
    func getWatchedMovies() -> [MovieData] {
        return getAllMovies().filter { _watchedMovies.keys.contains($0.id) }
    }
    
    func isWatched(_ movieId: UUID) -> Bool {
        return _watchedMovies.keys.contains(movieId)
    }
    
    // MARK: - Filtering and Sorting
    
    func getMoviesByGenre(_ genre: String) -> [MovieData] {
        return getAllMovies().filter { $0.genre == genre }
    }
    
    func getMoviesByStreamingService(_ service: String) -> [MovieData] {
        return getAllMovies().filter { $0.streamingServices.contains(service) }
    }
    
    func getMoviesSorted(by criteria: MovieSortCriteria) -> [MovieData] {
        let allMovies = getAllMovies()
        switch criteria {
        case .title, .alphabetical:
            return allMovies.sorted { $0.title < $1.title }
        case .year:
            return allMovies.sorted { $0.year < $1.year }
        case .rating:
            return allMovies.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .dateAdded:
            return allMovies.sorted { $0.title < $1.title } // Fallback
        }
    }
    
    // MARK: - Sample Data Setup
    
    private func setupSampleMovies() {
        movies = [
            // Preschoolers (2-4)
            MovieData(
                title: "Bluey: The Movie",
                year: 2024,
                ageGroup: .preschoolers,
                genre: "Animation",
                emoji: "🐕",
                streamingServices: ["Disney+"],
                rating: 4.9,
                notes: "Perfect for the youngest family members"
            ),
            MovieData(
                title: "Peppa Pig: My First Cinema Experience",
                year: 2017,
                ageGroup: .preschoolers,
                genre: "Animation",
                emoji: "🐷",
                streamingServices: ["Netflix", "Amazon Prime"],
                rating: 4.2
            ),
            
            // Little Kids (5-7)
            MovieData(
                title: "Moana",
                year: 2016,
                ageGroup: .littleKids,
                genre: "Animation",
                emoji: "🌊",
                streamingServices: ["Disney+"],
                rating: 4.7,
                notes: "Beautiful story about finding your way"
            ),
            MovieData(
                title: "Finding Nemo",
                year: 2003,
                ageGroup: .littleKids,
                genre: "Animation",
                emoji: "🐠",
                streamingServices: ["Disney+"],
                rating: 4.8
            ),
            MovieData(
                title: "Paddington",
                year: 2014,
                ageGroup: .littleKids,
                genre: "Family",
                emoji: "🧸",
                streamingServices: ["Netflix", "Hulu"],
                rating: 4.6,
                notes: "Charming bear with impeccable manners"
            ),
            
            // Big Kids (8-9)
            MovieData(
                title: "The Incredibles",
                year: 2004,
                ageGroup: .bigKids,
                genre: "Animation",
                emoji: "🦸‍♂️",
                streamingServices: ["Disney+"],
                rating: 4.8,
                notes: "Superhero family saves the day"
            ),
            MovieData(
                title: "Spider-Man: Into the Spider-Verse",
                year: 2018,
                ageGroup: .bigKids,
                genre: "Animation",
                emoji: "🕷️",
                streamingServices: ["Netflix", "Sony Pictures"],
                rating: 4.9
            ),
            MovieData(
                title: "How to Train Your Dragon",
                year: 2010,
                ageGroup: .bigKids,
                genre: "Animation",
                emoji: "🐉",
                streamingServices: ["Netflix", "Peacock"],
                rating: 4.7
            ),
            
            // Tweens (10-12)
            MovieData(
                title: "The Princess Bride",
                year: 1987,
                ageGroup: .tweens,
                genre: "Adventure",
                emoji: "👸",
                streamingServices: ["Disney+", "Hulu"],
                rating: 4.9,
                notes: "Classic adventure with romance and humor"
            ),
            MovieData(
                title: "Jumanji: Welcome to the Jungle",
                year: 2017,
                ageGroup: .tweens,
                genre: "Adventure",
                emoji: "🎮",
                streamingServices: ["Netflix", "Amazon Prime"],
                rating: 4.5
            ),
            MovieData(
                title: "The Karate Kid",
                year: 1984,
                ageGroup: .tweens,
                genre: "Drama",
                emoji: "🥋",
                streamingServices: ["Netflix", "Amazon Prime"],
                rating: 4.6,
                notes: "Wax on, wax off - timeless coming of age story"
            )
        ]
        
        // Add some movies to watchlist by default for testing
        if let moana = movies.first(where: { $0.title == "Moana" }) {
            addToWatchlist(moana.id)
        }
        if let incredibles = movies.first(where: { $0.title == "The Incredibles" }) {
            addToWatchlist(incredibles.id)
        }
    }
    
    // MARK: - Test Helper Methods
    
    func addSampleMovieToWatchlist() {
        if let firstMovie = movies.first {
            addToWatchlist(firstMovie.id)
        }
    }
    
    func clearAllData() {
        _watchlist.removeAll()
        _watchedMovies.removeAll()
    }
    
    func getWatchlistCount() -> Int {
        return _watchlist.count
    }
    
    func getWatchedCount() -> Int {
        return _watchedMovies.count
    }
    
    // MARK: - Movie Scheduling Operations (TDD Implementation)
    
    func scheduleMovie(_ movieId: UUID, for date: Date) {
        // Find the movie and update its scheduled date
        if let index = movies.firstIndex(where: { $0.id == movieId }) {
            movies[index].scheduledDate = date
            print("🎬 MockMovieService: Scheduled movie \(movieId) for \(date)")
        }
    }
    
    func unscheduleMovie(_ movieId: UUID) {
        if let index = movies.firstIndex(where: { $0.id == movieId }) {
            movies[index].scheduledDate = nil
            print("🎬 MockMovieService: Unscheduled movie \(movieId)")
        }
    }
    
    func getScheduledMovies() -> [MovieData] {
        return getAllMovies().filter { $0.scheduledDate != nil }
    }
    
    func isScheduled(_ movieId: UUID) -> Bool {
        return movies.first(where: { $0.id == movieId })?.scheduledDate != nil
    }
    
    func getScheduledDate(for movieId: UUID) -> Date? {
        return movies.first(where: { $0.id == movieId })?.scheduledDate
    }
    
    // MARK: - Additional Operations
    
    func refreshFromStorage() {
        // Mock implementation - no-op for testing
        print("🎬 MockMovieService: refreshFromStorage called")
    }
    
    func addMultipleToWatchlist(_ movieIds: [UUID]) {
        for movieId in movieIds {
            addToWatchlist(movieId)
        }
    }
    
    func clearWatchlist() {
        _watchlist.removeAll()
    }
    
    func getWatchlistStatistics() -> WatchlistStatistics {
        let watchlistMovies = getWatchlistMovies()
        let ageGroupCounts = Dictionary(grouping: watchlistMovies, by: { $0.ageGroup })
            .mapValues { $0.count }
        
        let averageRating = watchlistMovies.compactMap { $0.rating }.reduce(0, +) / Double(max(watchlistMovies.count, 1))
        
        return WatchlistStatistics(
            totalCount: _watchlist.count,
            ageGroupBreakdown: ageGroupCounts,
            averageRating: averageRating,
            totalWatchedFromWatchlist: watchlistMovies.filter { isWatched($0.id) }.count
        )
    }
}

// MARK: - Mock Memory Service

@Observable
class MockMemoryService: MemoryServiceProtocol {
    private var memories: [MemoryData] = []
    private var discussionAnswers: [DiscussionAnswer] = []
    
    func getAllMemories() -> [MemoryData] {
        return memories
    }
    
    func createMemory(_ memory: MemoryData) -> Bool {
        memories.append(memory)
        return true
    }
    
    func deleteMemory(_ memoryId: UUID) -> Bool {
        let initialCount = memories.count
        memories.removeAll { $0.id == memoryId }
        return memories.count < initialCount
    }
    
    func getMemory(by id: UUID) -> MemoryData? {
        return memories.first { $0.id == id }
    }
    
    func getMemories(for movieId: UUID) -> [MemoryData] {
        return memories.filter { $0.movieId == movieId }
    }
    
    func loadMemories() -> [MemoryData] {
        return memories
    }
    
    func saveDiscussionAnswer(_ answer: DiscussionAnswer, for memoryId: UUID) -> Bool {
        discussionAnswers.append(answer)
        return true
    }
    
    func getDiscussionAnswers(for memoryId: UUID) -> [DiscussionAnswer] {
        guard let memory = getMemory(by: memoryId) else { return [] }
        return memory.discussionAnswers
    }
    
    func getMemoryCount() -> Int {
        return memories.count
    }
    
    func getMemoriesSorted(by criteria: MemorySortCriteria) -> [MemoryData] {
        switch criteria {
        case .date:
            return memories.sorted { $0.watchDate > $1.watchDate }
        case .rating:
            return memories.sorted { $0.rating > $1.rating }
        case .movieTitle:
            return memories.sorted { $0.watchDate > $1.watchDate } // Fallback
        }
    }
    
    func searchMemories(query: String) -> [MemoryData] {
        guard !query.isEmpty else { return memories }
        return memories.filter { memory in
            memory.notes?.lowercased().contains(query.lowercased()) == true
        }
    }
    
    func getAverageRating() -> Double {
        guard !memories.isEmpty else { return 0.0 }
        let totalRating = memories.reduce(0) { $0 + $1.rating }
        return Double(totalRating) / Double(memories.count)
    }
}

// MARK: - Mock Data Providers - Moved to MockMovieDataProvider.swift to avoid duplication
// Note: MockMovieDataProvider and MockMemoryDataProvider are implemented in their respective files
