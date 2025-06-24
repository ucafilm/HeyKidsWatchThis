// MovieService.swift
// HeyKidsWatchThis - Phase 1: TDD Compilation Fix
// @Observable MovieService using modern iOS 17+ patterns
// Updated to fix compilation errors and use proper method signatures

import Foundation
import Observation

@Observable
class MovieService: MovieServiceProtocol {
    
    private let dataProvider: MovieDataProviderProtocol
    
    // MARK: - Public Read-Only Properties (Fix for access control)
    public private(set) var movies: [MovieData]
    // Watchlist property to conform to protocol
    var watchlist: [UUID] {
        return _watchlist
    }
    public private(set) var watchedMovies: [UUID: Date] {
        get { return _watchedMovies }
        set { _watchedMovies = newValue }
    }
    
    // MARK: - Private Implementation Properties
    private var _watchlist: [UUID]
    private var _watchedMovies: [UUID: Date]
    
    // MARK: - Initialization
    
    init(dataProvider: MovieDataProviderProtocol) {
        self.dataProvider = dataProvider
        self.movies = dataProvider.loadMovies()
        self._watchlist = dataProvider.loadWatchlist()
        self._watchedMovies = dataProvider.loadWatchedMovies()
        
        // If no movies loaded, provide sample data for testing
        if movies.isEmpty {
            movies = Self.createSampleMovies()
        }
    }
    
    // MARK: - Core Movie Operations
    
    func getAllMovies() -> [MovieData] {
        return movies.map { movie in
            var updatedMovie = movie
            updatedMovie.isInWatchlist = isInWatchlist(movie.id)
            updatedMovie.isWatched = isWatched(movie.id)
            return updatedMovie
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
    
    // MARK: - Watchlist Operations (Updated for Protocol Conformance)
    
    func addToWatchlist(_ movieId: UUID) {
        guard !_watchlist.contains(movieId) else { return }
        
        _watchlist.append(movieId)
        dataProvider.saveWatchlist(_watchlist)
    }
    
    func removeFromWatchlist(_ movieId: UUID) {
        _watchlist.removeAll { $0 == movieId }
        dataProvider.saveWatchlist(_watchlist)
    }
    
    func isInWatchlist(_ movieId: UUID) -> Bool {
        return _watchlist.contains(movieId)
    }
    
    func getWatchlistMovies() -> [MovieData] {
        return getAllMovies().filter { movie in
            _watchlist.contains(movie.id)
        }
    }
    
    // MARK: - Watched Movies Tracking
    
    func markAsWatched(_ movieId: UUID) {
        markAsWatched(movieId, date: Date())
    }
    
    func markAsWatched(_ movieId: UUID, date: Date) {
        _watchedMovies[movieId] = date
        dataProvider.saveWatchedMovies(_watchedMovies)
    }
    
    func getWatchedMovies() -> [MovieData] {
        return getAllMovies().filter { movie in
            _watchedMovies.keys.contains(movie.id)
        }
    }
    
    func isWatched(_ movieId: UUID) -> Bool {
        return _watchedMovies.keys.contains(movieId)
    }
    
    // MARK: - Filtering and Sorting
    
    func getMoviesByGenre(_ genre: String) -> [MovieData] {
        return getAllMovies().filter { $0.genre == genre }
    }
    
    func getMoviesByStreamingService(_ streamingService: String) -> [MovieData] {
        return getAllMovies().filter { movie in
            movie.streamingServices.contains(streamingService)
        }
    }
    
    func getMoviesSorted(by criteria: MovieSortCriteria) -> [MovieData] {
        let allMovies = getAllMovies()
        switch criteria {
        case .title, .alphabetical:
            return allMovies.sorted { $0.title < $1.title }
            
        case .year:
            return allMovies.sorted { $0.year < $1.year }
            
        case .rating:
            return allMovies.sorted { (movie1, movie2) in
                let rating1 = movie1.rating ?? 0
                let rating2 = movie2.rating ?? 0
                return rating1 > rating2 // Highest rating first
            }
            
        case .dateAdded:
            // Sort by title as fallback since we don't have dateAdded field
            return allMovies.sorted { $0.title < $1.title }
        }
    }
    
    // MARK: - Sample Data (Remove when you have real data)
    
    private static func createSampleMovies() -> [MovieData] {
        return [
            MovieData(
                title: "My Neighbor Totoro",
                year: 1988,
                ageGroup: .littleKids,
                genre: "Animation",
                emoji: "🌳",
                streamingServices: ["Netflix"],
                rating: 4.8,
                notes: "Beautiful Ghibli film"
            ),
            MovieData(
                title: "The Iron Giant",
                year: 1999,
                ageGroup: .bigKids,
                genre: "Animation",
                emoji: "🤖",
                streamingServices: ["Netflix", "Disney+"],
                rating: 4.7,
                notes: "Heartwarming robot story"
            ),
            MovieData(
                title: "Finding Nemo",
                year: 2003,
                ageGroup: .preschoolers,
                genre: "Animation",
                emoji: "🐠",
                streamingServices: ["Disney+"],
                rating: 4.6,
                notes: "Ocean adventure"
            ),
            MovieData(
                title: "Coco",
                year: 2017,
                ageGroup: .bigKids,
                genre: "Animation",
                emoji: "💀",
                streamingServices: ["Disney+"],
                rating: 4.8,
                notes: "Day of the Dead celebration"
            ),
            MovieData(
                title: "Spirited Away",
                year: 2001,
                ageGroup: .tweens,
                genre: "Animation",
                emoji: "🏮",
                streamingServices: ["Netflix"],
                rating: 4.9,
                notes: "Miyazaki masterpiece"
            ),
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
                title: "The Incredibles",
                year: 2004,
                ageGroup: .bigKids,
                genre: "Animation",
                emoji: "🦸‍♂️",
                streamingServices: ["Disney+"],
                rating: 4.8,
                notes: "Superhero family saves the day"
            )
        ]
    }
}

// MARK: - Mock Data Provider implementation removed - using separate MockMovieDataProvider.swift file
