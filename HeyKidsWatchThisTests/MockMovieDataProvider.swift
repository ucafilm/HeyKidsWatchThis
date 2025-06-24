import Foundation

/// Mock movie data provider for testing - conforms to MovieDataProviderProtocol
class MockMovieDataProvider: MovieDataProviderProtocol {
    private var movies: [MovieData] = [
        // Test movies for mock data provider
        MovieData(
            id: UUID(),
            title: "My Neighbor Totoro",
            year: 1988,
            ageGroup: .preschoolers,
            genre: "Animation",
            emoji: "🌳",
            streamingServices: ["Netflix"],
            rating: 4.8,
            notes: "Beautiful Ghibli film about friendship and imagination"
        ),
        MovieData(
            id: UUID(),
            title: "Toy Story",
            year: 1995,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🤠",
            streamingServices: ["Disney+"],
            rating: 4.8,
            notes: "Groundbreaking animation about friendship and loyalty"
        ),
        MovieData(
            id: UUID(),
            title: "The Iron Giant",
            year: 1999,
            ageGroup: .bigKids,
            genre: "Animation",
            emoji: "🤖",
            streamingServices: ["HBO Max"],
            rating: 4.6,
            notes: "Touching story about friendship between boy and robot"
        ),
        MovieData(
            id: UUID(),
            title: "Spirited Away",
            year: 2001,
            ageGroup: .tweens,
            genre: "Animation",
            emoji: "🏮",
            streamingServices: ["Netflix"],
            rating: 4.9,
            notes: "Miyazaki masterpiece about courage and growing up"
        )
    ]
    
    private var watchlist: [UUID] = []
    private var watchedMovies: [UUID: Date] = [:]
    
    // MARK: - MovieDataProviderProtocol Implementation
    
    func loadMovies() -> [MovieData] {
        return movies
    }
    
    func saveWatchlist(_ watchlist: [UUID]) {
        self.watchlist = watchlist
    }
    
    func loadWatchlist() -> [UUID] {
        return watchlist
    }
    
    func saveWatchedMovies(_ watchedMovies: [UUID: Date]) {
        self.watchedMovies = watchedMovies
    }
    
    func loadWatchedMovies() -> [UUID: Date] {
        return watchedMovies
    }
    
    // MARK: - Additional Helper Methods for Testing
    
    /// Add a movie to the mock data (for testing)
    func addMovie(_ movie: MovieData) {
        movies.append(movie)
    }
    
    /// Reset all data (for testing)
    func reset() {
        watchlist.removeAll()
        watchedMovies.removeAll()
    }
}
