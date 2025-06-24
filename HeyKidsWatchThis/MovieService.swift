// In HeyKidsWatchThis/MovieService.swift

import Foundation
import os.log
import Observation

@Observable
class MovieService: MovieServiceProtocol {
    
    private let dataProvider: MovieDataProviderProtocol
    private var _movies: [MovieData]
    private var _watchlist: Set<UUID> // Using Set for O(1) performance
    private var _watchedMovies: [UUID: Date]
    
    private let logger = Logger(subsystem: "com.heykidswatchthis.app", category: "MovieService")
    
    init(dataProvider: MovieDataProviderProtocol) {
        self.dataProvider = dataProvider
        self._movies = dataProvider.loadMovies()
        self._watchlist = Set(dataProvider.loadWatchlist())
        self._watchedMovies = dataProvider.loadWatchedMovies()
        logger.info("🎬 MovieService initialized: \(self._movies.count) movies, \(self._watchlist.count) in watchlist")
    }
    
    func getAllMovies() -> [MovieData] {
        return _movies.map { movie in
            var updatedMovie = movie
            updatedMovie.isInWatchlist = _watchlist.contains(movie.id)
            updatedMovie.isWatched = _watchedMovies.keys.contains(movie.id)
            return updatedMovie
        }
    }

    func getMovie(by id: UUID) -> MovieData? {
        return getAllMovies().first { $0.id == id }
    }
    
    var watchlist: [UUID] {
        return Array(_watchlist)
    }
    
    func addToWatchlist(_ movieId: UUID) {
        if _watchlist.insert(movieId).inserted {
            dataProvider.saveWatchlist(Array(_watchlist))
            logger.info("🎬 Added movie \(movieId) to watchlist. New size: \(self._watchlist.count)")
        }
    }
    
    func removeFromWatchlist(_ movieId: UUID) {
        if _watchlist.remove(movieId) != nil {
            dataProvider.saveWatchlist(Array(_watchlist))
            logger.info("🎬 Removed movie \(movieId) from watchlist. New size: \(self._watchlist.count)")
        }
    }
    
    func isInWatchlist(_ movieId: UUID) -> Bool {
        return _watchlist.contains(movieId)
    }

    func getWatchlistMovies() -> [MovieData] {
        return getAllMovies().filter { _watchlist.contains($0.id) }
    }

    func scheduleMovie(_ movieId: UUID, for date: Date) {
        if let index = _movies.firstIndex(where: { $0.id == movieId }) {
            _movies[index].scheduledDate = date
            logger.info("🎬 Scheduled movie \(movieId) for \(date)")
            // In a real app, you would persist this change to the dataProvider.
        }
    }

    // --- Implement other protocol methods similarly ---
    func getMovies(for ageGroup: AgeGroup) -> [MovieData] { return getAllMovies().filter { $0.ageGroup == ageGroup } }
    func searchMovies(_ query: String) -> [MovieData] { return getAllMovies().filter { $0.title.localizedStandardContains(query) } }
    func markAsWatched(_ movieId: UUID) { markAsWatched(movieId, date: Date()) }
    func markAsWatched(_ movieId: UUID, date: Date) { _watchedMovies[movieId] = date; dataProvider.saveWatchedMovies(_watchedMovies) }
    func getWatchedMovies() -> [MovieData] { return getAllMovies().filter { isWatched($0.id) } }
    func isWatched(_ movieId: UUID) -> Bool { return _watchedMovies.keys.contains(movieId) }
    func unscheduleMovie(_ movieId: UUID) { if let index = _movies.firstIndex(where: { $0.id == movieId }) { _movies[index].scheduledDate = nil } }
    func getScheduledMovies() -> [MovieData] { return getAllMovies().filter { $0.scheduledDate != nil } }
    func isScheduled(_ movieId: UUID) -> Bool { return getMovie(by: movieId)?.scheduledDate != nil }
    func getScheduledDate(for movieId: UUID) -> Date? { return getMovie(by: movieId)?.scheduledDate }
    func getMoviesByGenre(_ genre: String) -> [MovieData] { return getAllMovies().filter { $0.genre == genre } }
    func getMoviesByStreamingService(_ streamingService: String) -> [MovieData] { return getAllMovies().filter { $0.streamingServices.contains(streamingService) } }
    func getMoviesSorted(by criteria: MovieSortCriteria) -> [MovieData] { return getAllMovies().sorted { $0.title < $1.title } }
    func refreshFromStorage() { _watchlist = Set(dataProvider.loadWatchlist()) }
    
    // MARK: - Bulk Operations & Statistics (FIXES COMPILATION ERRORS)
    
    func addMultipleToWatchlist(_ movieIds: [UUID]) {
        let validMovieIds = movieIds.filter { movieId in
            _movies.contains(where: { $0.id == movieId }) && !_watchlist.contains(movieId)
        }
        
        for movieId in validMovieIds {
            _watchlist.insert(movieId)
        }
        
        if !validMovieIds.isEmpty {
            let watchlistArray = Array(_watchlist)
            dataProvider.saveWatchlist(watchlistArray)
            
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
