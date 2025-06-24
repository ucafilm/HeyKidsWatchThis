// EnhancedMovieService.swift
// HeyKidsWatchThis - Enhanced Movie Service with File Storage
// Fixes: UserDefaults 4MB limit causing watchlist corruption

import Foundation
import os.log
import Observation

@Observable
class EnhancedMovieService: MovieServiceProtocol {
    
    // MARK: - Properties
    
    private let dataProvider: EnhancedMovieDataProvider
    private var _movies: [MovieData]
    private var _watchlist: Set<UUID>
    private var _watchedMovies: [UUID: Date]
    
    private let logger = Logger(subsystem: "com.heykidswatchthis.app", category: "EnhancedMovieService")
    
    // MARK: - Initialization
    
    init(dataProvider: EnhancedMovieDataProvider? = nil) {
        self.dataProvider = dataProvider ?? EnhancedMovieDataProvider()
        self._movies = self.dataProvider.loadMovies()
        self._watchlist = Set(self.dataProvider.loadWatchlist())
        self._watchedMovies = self.dataProvider.loadWatchedMovies()
        
        logger.info("🎬 Enhanced MovieService initialized: \(self._movies.count) movies, \(self._watchlist.count) in watchlist")
    }
    
    // Convenience initializer for existing code
    convenience init() {
        self.init(dataProvider: nil)
    }
    
    // MARK: - Core Movie Operations
    
    func getAllMovies() -> [MovieData] {
        return _movies.map { movie in
            var updatedMovie = movie
            updatedMovie.isInWatchlist = _watchlist.contains(movie.id)
            updatedMovie.isWatched = _watchedMovies.keys.contains(movie.id)
            
            if _watchlist.contains(movie.id) {
                print("🔄 Syncing movie '\(movie.title)' - isInWatchlist: \(updatedMovie.isInWatchlist)")
            }
            
            return updatedMovie
        }
    }
    
    func getMovies(for ageGroup: AgeGroup) -> [MovieData] {
        return getAllMovies().filter { $0.ageGroup == ageGroup }
    }
    
    func searchMovies(_ query: String) -> [MovieData] {
        guard !query.isEmpty else { return getAllMovies() }
        
        return getAllMovies().filter { movie in
            movie.title.localizedStandardContains(query) ||
            movie.genre.localizedStandardContains(query) ||
            movie.notes?.localizedStandardContains(query) == true
        }
    }
    
    func getMovie(by id: UUID) -> MovieData? {
        return getAllMovies().first { $0.id == id }
    }
    
    // MARK: - Watchlist Operations
    
    var watchlist: [UUID] {
        return Array(_watchlist)
    }
    
    func addToWatchlist(_ movieId: UUID) {
        guard !_watchlist.contains(movieId) else {
            logger.debug("🎬 Movie \(movieId) already in watchlist, skipping")
            return
        }
        
        guard _movies.contains(where: { $0.id == movieId }) else {
            logger.error("🎬 ERROR: Attempted to add non-existent movie \(movieId) to watchlist")
            return
        }
        
        _watchlist.insert(movieId)
        dataProvider.saveWatchlist(Array(_watchlist))
        
        if let movie = _movies.first(where: { $0.id == movieId }) {
            logger.info("🎬 Added movie '\(movie.title)' to watchlist. New size: \(self._watchlist.count)")
        }
    }
    
    func removeFromWatchlist(_ movieId: UUID) {
        let removedElement = _watchlist.remove(movieId)
        
        if removedElement != nil {
            dataProvider.saveWatchlist(Array(_watchlist))
            
            if let movie = _movies.first(where: { $0.id == movieId }) {
                logger.info("🎬 Removed movie '\(movie.title)' from watchlist. New size: \(self._watchlist.count)")
            }
        }
    }
    
    func isInWatchlist(_ movieId: UUID) -> Bool {
        return _watchlist.contains(movieId)
    }
    
    func getWatchlistMovies() -> [MovieData] {
        return getAllMovies().filter { _watchlist.contains($0.id) }
    }
    
    // MARK: - Movie Scheduling
    
    func scheduleMovie(_ movieId: UUID, for date: Date) {
        if let index = _movies.firstIndex(where: { $0.id == movieId }) {
            _movies[index].scheduledDate = date
            _ = dataProvider.saveMovies(_movies)
            
            if let movie = _movies.first(where: { $0.id == movieId }) {
                logger.info("🎬 Scheduled movie '\(movie.title)' for \(date)")
            }
        }
    }
    
    func unscheduleMovie(_ movieId: UUID) {
        if let index = _movies.firstIndex(where: { $0.id == movieId }) {
            _movies[index].scheduledDate = nil
            _ = dataProvider.saveMovies(_movies)
            
            if let movie = _movies.first(where: { $0.id == movieId }) {
                logger.info("🎬 Unscheduled movie '\(movie.title)'")
            }
        }
    }
    
    func getScheduledMovies() -> [MovieData] {
        return getAllMovies().filter { $0.scheduledDate != nil }
    }
    
    func isScheduled(_ movieId: UUID) -> Bool {
        return _movies.first(where: { $0.id == movieId })?.scheduledDate != nil
    }
    
    func getScheduledDate(for movieId: UUID) -> Date? {
        return _movies.first(where: { $0.id == movieId })?.scheduledDate
    }
    
    // MARK: - Watched Movies
    
    func markAsWatched(_ movieId: UUID) {
        markAsWatched(movieId, date: Date())
    }
    
    func markAsWatched(_ movieId: UUID, date: Date) {
        guard _movies.contains(where: { $0.id == movieId }) else {
            logger.error("🎬 ERROR: Attempted to mark non-existent movie \(movieId) as watched")
            return
        }
        
        _watchedMovies[movieId] = date
        dataProvider.saveWatchedMovies(_watchedMovies)
        
        if let movie = _movies.first(where: { $0.id == movieId }) {
            logger.info("🎬 Marked movie '\(movie.title)' as watched on \(date)")
        }
    }
    
    func getWatchedMovies() -> [MovieData] {
        return getAllMovies().filter { _watchedMovies.keys.contains($0.id) }
    }
    
    func isWatched(_ movieId: UUID) -> Bool {
        return _watchedMovies.keys.contains(movieId)
    }
    
    // MARK: - Additional Operations
    
    func getMoviesByGenre(_ genre: String) -> [MovieData] {
        return getAllMovies().filter { $0.genre == genre }
    }
    
    func getMoviesByStreamingService(_ streamingService: String) -> [MovieData] {
        return getAllMovies().filter { movie in
            movie.streamingServices.contains(streamingService)
        }
    }
    
    func getMoviesSorted(by criteria: MovieSortCriteria) -> [MovieData] {
        let movies = getAllMovies()
        
        switch criteria {
        case .title, .alphabetical:
            return movies.sorted { $0.title < $1.title }
        case .year:
            return movies.sorted { $0.year < $1.year }
        case .rating:
            return movies.sorted { (movie1, movie2) in
                let rating1 = movie1.rating ?? 0
                let rating2 = movie2.rating ?? 0
                return rating1 > rating2
            }
        case .dateAdded:
            return movies.sorted { $0.title < $1.title }
        }
    }
    
    // MARK: - Refresh and State Management
    
    func refreshFromStorage() {
        let previousWatchlistSize = _watchlist.count
        
        _movies = dataProvider.loadMovies()
        _watchlist = Set(dataProvider.loadWatchlist())
        _watchedMovies = dataProvider.loadWatchedMovies()
        
        logger.info("🎬 Refreshed from storage. Movies: \(self._movies.count), Watchlist: \(previousWatchlistSize) → \(self._watchlist.count)")
    }
    
    // MARK: - Debug Helper
    
    func getDebugInfo() -> String {
        var info = dataProvider.getDebugInfo()
        info += "\n🎬 Service State:"
        info += "\nLoaded movies: \(_movies.count)"
        info += "\nActive watchlist: \(_watchlist.count)"
        info += "\nWatched movies: \(_watchedMovies.count)"
        
        // Show sample of watchlist IDs and movie IDs
        info += "\n\n🔍 ID Matching Debug:"
        let movieIds = _movies.prefix(3).map(\.id)
        let watchlistIds = Array(_watchlist.prefix(3))
        
        info += "\nSample Movie IDs: \(movieIds)"
        info += "\nSample Watchlist IDs: \(watchlistIds)"
        
        // Check for Mermaid movie specifically
        if let mermaidMovie = _movies.first(where: { $0.title == "Mermaid" }) {
            info += "\n🧜‍♀️ Mermaid Movie: ID=\(mermaidMovie.id), InWatchlist=\(_watchlist.contains(mermaidMovie.id))"
        }
        
        return info
    }
    
    // MARK: - Bulk Operations
    
    func addMultipleToWatchlist(_ movieIds: [UUID]) {
        let validMovieIds = movieIds.filter { movieId in
            _movies.contains(where: { $0.id == movieId }) && !_watchlist.contains(movieId)
        }
        
        for movieId in validMovieIds {
            _watchlist.insert(movieId)
        }
        
        if !validMovieIds.isEmpty {
            dataProvider.saveWatchlist(Array(_watchlist))
            logger.info("🎬 Bulk added \(validMovieIds.count) movies to watchlist. New size: \(self._watchlist.count)")
        }
    }
    
    func clearWatchlist() {
        let previousSize = _watchlist.count
        _watchlist.removeAll()
        dataProvider.saveWatchlist([])
        
        logger.info("🎬 Cleared watchlist. Removed \(previousSize) movies")
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
