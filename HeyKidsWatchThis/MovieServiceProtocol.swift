// MovieServiceProtocol.swift
// HeyKidsWatchThis - Single source of truth for movie service protocols

import Foundation

// ============================================================================
// MARK: - Movie Service Protocol (SINGLE DEFINITION)
// ============================================================================

/// Movie service protocol following established patterns
protocol MovieServiceProtocol {
    // Core movie operations
    func getAllMovies() -> [MovieData]
    func getMovies(for ageGroup: AgeGroup) -> [MovieData]
    func searchMovies(_ query: String) -> [MovieData]
    func getMovie(by id: UUID) -> MovieData?
    
    // Watchlist operations
    var watchlist: [UUID] { get }
    func addToWatchlist(_ movieId: UUID)
    func removeFromWatchlist(_ movieId: UUID)
    func isInWatchlist(_ movieId: UUID) -> Bool
    func getWatchlistMovies() -> [MovieData]
    
    // Watched movies tracking
    func markAsWatched(_ movieId: UUID)
    func markAsWatched(_ movieId: UUID, date: Date)
    func getWatchedMovies() -> [MovieData]
    func isWatched(_ movieId: UUID) -> Bool
    
    // MARK: - Movie Scheduling
    func scheduleMovie(_ movieId: UUID, for date: Date)
    func unscheduleMovie(_ movieId: UUID)
    func getScheduledMovies() -> [MovieData]
    func isScheduled(_ movieId: UUID) -> Bool
    func getScheduledDate(for movieId: UUID) -> Date?
    
    // MARK: - Filtering and sorting
    func getMoviesByGenre(_ genre: String) -> [MovieData]
    func getMoviesByStreamingService(_ streamingService: String) -> [MovieData]
    func getMoviesSorted(by criteria: MovieSortCriteria) -> [MovieData]
    
    // MARK: - Bulk Operations & Statistics (FIXES COMPILATION ERRORS)
    func clearWatchlist()
    func addMultipleToWatchlist(_ movieIds: [UUID])
    func getWatchlistStatistics() -> WatchlistStatistics
}

// ============================================================================
// MARK: - Movie Data Provider Protocol (SINGLE DEFINITION)
// ============================================================================

/// Movie data provider protocol - CONSOLIDATED to prevent conflicts
protocol MovieDataProviderProtocol {
    func loadMovies() -> [MovieData]
    func saveWatchlist(_ watchlist: [UUID])
    func loadWatchlist() -> [UUID]
    func saveWatchedMovies(_ watchedMovies: [UUID: Date])
    func loadWatchedMovies() -> [UUID: Date]
}

// ============================================================================
// MARK: - Supporting Types (SINGLE DEFINITION)
// ============================================================================

/// Movie sorting criteria
enum MovieSortCriteria {
    case title
    case year
    case rating
    case dateAdded
    case alphabetical
}

/// Statistics about the user's watchlist
struct WatchlistStatistics {
    let totalCount: Int
    let ageGroupBreakdown: [AgeGroup: Int]
    let averageRating: Double
    let totalWatchedFromWatchlist: Int
    
    var completionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(totalWatchedFromWatchlist) / Double(totalCount) * 100
    }
}
