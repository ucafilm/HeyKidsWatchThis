// WatchlistViewModel.swift
// HeyKidsWatchThis - Phase 1: TDD Compilation Fix
// @Observable ViewModel for Watchlist functionality
// Modern iOS 17+ patterns with comprehensive state management
// FIXED: Uses WatchlistStatistics from MovieServiceProtocol.swift

import SwiftUI
import Observation
import Foundation

// Note: WatchlistStatistics is defined in MovieServiceProtocol.swift

// MARK: - Supporting Types

enum WatchlistSortOrder: String, CaseIterable {
    case dateAdded = "Date Added"
    case rating = "Rating" 
    case title = "Title"
    case ageGroup = "Age Group"
}

// Note: WatchlistStatistics is defined in MovieServiceProtocol.swift to avoid duplication

// MARK: - WatchlistViewModel

@Observable
class WatchlistViewModel {
    // Services
    private let movieService: MovieServiceProtocol
    let eventKitService: EventKitServiceProtocol
    
    // Core state
    var watchlistMovies: [MovieData] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Search & filtering
    var searchText: String = ""
    var selectedSortOrder: WatchlistSortOrder = .dateAdded
    
    // Calendar integration
    var nextMovieNight: MovieNightEvent?
    var randomMovieRequested: Bool = false
    
    // Computed properties
    var filteredWatchlist: [MovieData] {
        let filtered = searchText.isEmpty ? watchlistMovies : 
            watchlistMovies.filter { $0.title.localizedStandardContains(searchText) }
        
        return sortMovies(filtered, by: selectedSortOrder)
    }
    
    var watchlistStatistics: WatchlistStatistics? {
        guard !watchlistMovies.isEmpty else { return nil }
        
        let totalCount = watchlistMovies.count
        let ratings = watchlistMovies.compactMap(\.rating)
        let averageRating = ratings.isEmpty ? 0.0 : ratings.reduce(0, +) / Double(ratings.count)
        let watchedCount = watchlistMovies.filter(\.isWatched).count
        
        // Create age group breakdown
        let ageGroupBreakdown = Dictionary(grouping: watchlistMovies, by: { $0.ageGroup })
            .mapValues { $0.count }
        
        return WatchlistStatistics(
            totalCount: totalCount,
            ageGroupBreakdown: ageGroupBreakdown,
            averageRating: averageRating,
            totalWatchedFromWatchlist: watchedCount
        )
    }
    
    // Initialization
    init(movieService: MovieServiceProtocol, eventKitService: EventKitServiceProtocol) {
        self.movieService = movieService
        self.eventKitService = eventKitService
    }
    
    // MARK: - Actions
    
    @MainActor
    func loadWatchlistData() async {
        isLoading = true
        defer { isLoading = false }
        
        // FIXED: Get all movies and filter for watchlist items
        let allMovies = movieService.getAllMovies()
        watchlistMovies = allMovies.filter { $0.isInWatchlist }
        
        // Load upcoming movie nights
        nextMovieNight = await eventKitService.getUpcomingMovieNights(limit: 1).first
        
        errorMessage = nil
    }
    
    @MainActor
    func refreshWatchlist() async {
        await loadWatchlistData()
    }
    
    func removeFromWatchlist(_ movie: MovieData) {
        movieService.removeFromWatchlist(movie.id)
        watchlistMovies.removeAll { $0.id == movie.id }
    }
    
    func markAsWatched(_ movie: MovieData) {
        movieService.markAsWatched(movie.id)
        if let index = watchlistMovies.firstIndex(where: { $0.id == movie.id }) {
            var updatedMovie = watchlistMovies[index]
            updatedMovie.isWatched = true
            watchlistMovies[index] = updatedMovie
        }
    }
    
    func getRandomMovie() -> MovieData? {
        randomMovieRequested.toggle()
        return watchlistMovies.randomElement()
    }
    
    func suggestMovieForTonight() {
        // Implementation for tonight's suggestion
        // This could involve AI-based recommendations
        randomMovieRequested.toggle()
    }
    
    func reorderWatchlist(from source: IndexSet, to destination: Int) {
        watchlistMovies.move(fromOffsets: source, toOffset: destination)
    }
    
    func removeMoviesFromWatchlist(at offsets: IndexSet) {
        for index in offsets {
            let movie = watchlistMovies[index]
            removeFromWatchlist(movie)
        }
    }
    
    func sortWatchlist(by order: WatchlistSortOrder) {
        selectedSortOrder = order
    }
    
    func clearWatchlist() {
        for movie in watchlistMovies {
            movieService.removeFromWatchlist(movie.id)
        }
        watchlistMovies.removeAll()
    }
    
    func handleMovieNightScheduled(_ event: MovieNightEvent) {
        nextMovieNight = event
    }
    
    // MARK: - Private Helpers
    
    private func sortMovies(_ movies: [MovieData], by order: WatchlistSortOrder) -> [MovieData] {
        switch order {
        case .dateAdded:
            return movies // Assuming chronological order based on array position
        case .rating:
            return movies.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .title:
            return movies.sorted { $0.title < $1.title }
        case .ageGroup:
            return movies.sorted { $0.ageGroup.rawValue < $1.ageGroup.rawValue }
        }
    }
}

// MARK: - Extensions

extension WatchlistSortOrder: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}


