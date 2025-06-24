// MovieListViewModel.swift
// HeyKidsWatchThis - Enhanced ViewModel Implementation (Consolidated)
// Primary MovieListViewModel with enhanced @Observable integration and proper state management
// Based on iOS 17+ @Observable best practices and TDD requirements
// CONSOLIDATED: Was EnhancedMovieListViewModel.swift - now the primary implementation

import SwiftUI
import Observation
import os.log

@Observable
class MovieListViewModel {
    
    // MARK: - Dependencies
    
    let movieService: MovieServiceProtocol
    private let logger = Logger(subsystem: "com.heykidswatchthis.app", category: "MovieListViewModel")
    
    // MARK: - Core Properties
    
    var movies: [MovieData] = []
    var isLoading: Bool = false
    
    // MARK: - Search & Filtering Properties
    
    var searchText: String = ""
    var selectedAgeGroup: AgeGroup? = nil
    var selectedGenre: String? = nil
    var selectedStreamingService: String? = nil
    
    // MARK: - @Observable State Triggers (Critical for UI Updates)
    
    private var _watchlistStateVersion: Int = 0
    private var _watchedStateVersion: Int = 0
    private var _moviesStateVersion: Int = 0
    
    // MARK: - Initialization
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
        logger.info("🎬 MovieListViewModel initialized")
        loadMovies()
    }
    
    // MARK: - Data Loading with State Synchronization
    
    func loadMovies() {
        logger.debug("🎬 loadMovies called")
        isLoading = true
        
        // CRITICAL FIX: Refresh service from storage first
        if let movieService = movieService as? MovieService {
            movieService.refreshFromStorage()
        }
        
        DispatchQueue.main.async {
            // CRITICAL FIX: Always get fresh data with synchronized state
            self.movies = self.movieService.getAllMovies()
            self.isLoading = false
            self._moviesStateVersion += 1 // Trigger @Observable update
            
            self.logger.info("🎬 Loaded \(self.movies.count) movies with synchronized state")
        }
    }
    
    // MARK: - Computed Properties with Performance Optimization
    
    var filteredMovies: [MovieData] {
        // Access state version to ensure @Observable tracking
        _ = _moviesStateVersion
        
        var result = movies
        
        // Apply search text filter first (most common use case)
        if !searchText.isEmpty {
            result = result.filter { movie in
                movie.title.localizedStandardContains(self.searchText) ||
                movie.genre.localizedStandardContains(self.searchText) ||
                movie.notes?.localizedStandardContains(self.searchText) == true
            }
        }
        
        // Apply age group filter
        if let ageGroup = selectedAgeGroup {
            result = result.filter { $0.ageGroup == ageGroup }
        }
        
        // Apply genre filter
        if let genre = selectedGenre {
            result = result.filter { $0.genre == genre }
        }
        
        // Apply streaming service filter
        if let service = selectedStreamingService {
            result = result.filter { $0.streamingServices.contains(service) }
        }
        
        return result
    }
    
    var availableGenres: [String] {
        let allGenres = self.movies.map { $0.genre }
        return Array(Set(allGenres)).sorted()
    }
    
    var availableStreamingServices: [String] {
        let allServices = self.movies.flatMap { $0.streamingServices }
        return Array(Set(allServices)).sorted()
    }
    
    var hasActiveFilters: Bool {
        return !searchText.isEmpty ||
               selectedAgeGroup != nil ||
               selectedGenre != nil ||
               selectedStreamingService != nil
    }
    
    var activeFilterCount: Int {
        var count = 0
        if !searchText.isEmpty { count += 1 }
        if selectedAgeGroup != nil { count += 1 }
        if selectedGenre != nil { count += 1 }
        if selectedStreamingService != nil { count += 1 }
        return count
    }
    
    // MARK: - Enhanced Watchlist Operations with @Observable Support
    
    func isInWatchlist(_ movie: MovieData) -> Bool {
        // Access state version to ensure @Observable tracking
        _ = _watchlistStateVersion
        return movieService.isInWatchlist(movie.id)
    }
    
    func isWatched(_ movie: MovieData) -> Bool {
        // Access state version to ensure @Observable tracking
        _ = _watchedStateVersion
        return movieService.isWatched(movie.id)
    }
    
    @MainActor
    func toggleWatchlist(for movie: MovieData) {
        logger.debug("🎬 toggleWatchlist called for '\(movie.title)'")
        
        let wasInWatchlist = isInWatchlist(movie)
        logger.debug("🎬 Before toggle - isInWatchlist: \(wasInWatchlist)")
        
        // Apply the change
        if wasInWatchlist {
            movieService.removeFromWatchlist(movie.id)
        } else {
            movieService.addToWatchlist(movie.id)
        }
        
        // CRITICAL FIX: Force state synchronization
        refreshMovieState()
        
        let nowInWatchlist = isInWatchlist(movie)
        logger.debug("🎬 After toggle - isInWatchlist: \(nowInWatchlist)")
        
        // CRITICAL FIX: Trigger @Observable updates
        _watchlistStateVersion += 1
        _moviesStateVersion += 1
        
        // CRITICAL FIX: Add haptic feedback for better UX
        triggerHapticFeedback(for: .watchlistToggle)
        
        logger.info("🎬 Watchlist toggled for '\(movie.title)': \(wasInWatchlist) → \(nowInWatchlist)")
    }
    
    @MainActor
    func markAsWatched(_ movie: MovieData) {
        logger.debug("🎬 markAsWatched called for '\(movie.title)'")
        
        guard !isWatched(movie) else {
            logger.debug("🎬 Movie '\(movie.title)' already watched, skipping")
            return
        }
        
        let wasWatched = isWatched(movie)
        
        movieService.markAsWatched(movie.id, date: Date())
        
        // CRITICAL FIX: Force state synchronization
        refreshMovieState()
        
        let nowWatched = isWatched(movie)
        logger.debug("🎬 After mark - isWatched: \(nowWatched)")
        
        // CRITICAL FIX: Trigger @Observable updates
        _watchedStateVersion += 1
        _moviesStateVersion += 1
        
        // CRITICAL FIX: Add success haptic feedback
        triggerHapticFeedback(for: .watched)
        
        logger.info("🎬 Marked '\(movie.title)' as watched: \(wasWatched) → \(nowWatched)")
    }
    
    // MARK: - State Synchronization Methods
    
    private func refreshMovieState() {
        // CRITICAL FIX: Reload movies to get updated state
        self.movies = movieService.getAllMovies()
        logger.debug("🎬 Refreshed movie state. Movies count: \(self.movies.count)")
    }
    
    // MARK: - Filter Management
    
    func clearAllFilters() {
        logger.debug("🎬 Clearing all filters")
        
        searchText = ""
        selectedAgeGroup = nil
        selectedGenre = nil
        selectedStreamingService = nil
        
        logger.info("🎬 All filters cleared")
    }
    
    func applyQuickFilter(ageGroup: AgeGroup) {
        clearAllFilters()
        selectedAgeGroup = ageGroup
        logger.info("🎬 Applied quick filter for age group: \(ageGroup)")
    }
    
    // MARK: - Enhanced Watchlist Management
    
    func getWatchlistMovies() -> [MovieData] {
        _ = _watchlistStateVersion // Ensure tracking
        return movieService.getWatchlistMovies()
    }
    
    var watchlistCount: Int {
        _ = _watchlistStateVersion // Ensure tracking
        return movieService.watchlist.count
    }
    
    func clearWatchlist() {
        logger.debug("🎬 Clearing entire watchlist")
        
        if let movieService = movieService as? MovieService {
            movieService.clearWatchlist()
        } else {
            // Fallback for standard service
            let watchlistMovies = getWatchlistMovies()
            watchlistMovies.forEach { movie in
            self.movieService.removeFromWatchlist(movie.id)
            }
        }
        
        refreshMovieState()
        _watchlistStateVersion += 1
        _moviesStateVersion += 1
        
        triggerHapticFeedback(for: .watchlistClear)
        
        logger.info("🎬 Watchlist cleared completely")
    }
    
    // MARK: - Bulk Operations
    
    func addToWatchlistBulk(movies: [MovieData]) {
        let movieIds = movies.map { $0.id }
        
        if let movieService = movieService as? MovieService {
            movieService.addMultipleToWatchlist(movieIds)
        } else {
            // Fallback for standard service
            movieIds.forEach { movieId in self.movieService.addToWatchlist(movieId) }
        }
        
        refreshMovieState()
        _watchlistStateVersion += 1
        _moviesStateVersion += 1
        
        logger.info("🎬 Bulk added \(movies.count) movies to watchlist")
    }
    
    // MARK: - Analytics and Statistics
    
    func getWatchlistStatistics() -> WatchlistStatistics? {
        if let movieService = movieService as? MovieService {
            return movieService.getWatchlistStatistics()
        }
        return nil
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHapticFeedback(for action: HapticAction) {
        DispatchQueue.main.async {
            switch action {
            case .watchlistToggle:
                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.impactOccurred()
                
            case .watched:
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
                
            case .watchlistClear:
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.warning)
            }
        }
    }
    
    // MARK: - Debug and Development
    
    func printDebugInfo() {
        logger.info("🎬 DEBUG INFO:")
        logger.info("  Movies: \(self.movies.count)")
        logger.info("  Filtered Movies: \(self.filteredMovies.count)")
        logger.info("  Watchlist Count: \(self.watchlistCount)")
        logger.info("  Active Filters: \(self.activeFilterCount)")
        logger.info("  Search Text: '\(self.searchText)'")
        logger.info("  Selected Age Group: \(self.selectedAgeGroup?.description ?? "None")")
        logger.info("  Loading: \(self.isLoading)")
    }
}

// MARK: - Supporting Types

enum HapticAction {
    case watchlistToggle
    case watched
    case watchlistClear
}

// MARK: - ObservableObject Compatibility (For Migration)

extension MovieListViewModel: ObservableObject {
    // Explicit ObservableObject conformance for compatibility during migration
    // This can be removed once fully migrated to @Observable
}

// MARK: - Performance Monitoring Extension

extension MovieListViewModel {
    
    func measureFilteringPerformance() -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = filteredMovies // Trigger filtering
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        logger.debug("🎬 Filtering performance: \(duration * 1000)ms for \(self.movies.count) movies")
        return duration
    }
    
    var isPerformanceOptimal: Bool {
        let duration = measureFilteringPerformance()
        return duration < 0.016 // 60fps target
    }
}

// MARK: - Convenience Extensions

extension MovieListViewModel {
    
    var isEmpty: Bool {
        return self.movies.isEmpty
    }
    
    var hasSearchResults: Bool {
        return !searchText.isEmpty && !filteredMovies.isEmpty
    }
    
    var isFilteredEmpty: Bool {
        return hasActiveFilters && filteredMovies.isEmpty
    }
    
    func getMovieById(_ id: UUID) -> MovieData? {
        return self.movies.first { $0.id == id }
    }
    
    func getRandomMovie(from movies: [MovieData] = []) -> MovieData? {
        let sourceMovies = movies.isEmpty ? filteredMovies : movies
        return sourceMovies.randomElement()
    }
    
    func getRandomWatchlistMovie() -> MovieData? {
        return getWatchlistMovies().randomElement()
    }
}
