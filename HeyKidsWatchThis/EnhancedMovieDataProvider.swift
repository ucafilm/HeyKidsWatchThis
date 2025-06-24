// EnhancedMovieDataProvider.swift
// HeyKidsWatchThis - File-Based Storage Solution
// Fixes: UserDefaults 4MB limit causing watchlist corruption
// Solution: Move large data to file storage, keep only IDs in UserDefaults

import Foundation
import os.log

// MARK: - Enhanced File-Based Storage Manager
class EnhancedFileManager {
    private let logger = Logger(subsystem: "com.heykidswatchthis.app", category: "FileStorage")
    
    private let documentsDirectory: URL
    private let moviesFileName = "movies.json"
    private let watchlistFileName = "watchlist.json"
    private let watchedMoviesFileName = "watched_movies.json"
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logger.info("📂 Enhanced file storage initialized at: \(self.documentsDirectory.path)")
    }
    
    // MARK: - Movies Storage (File-based)
    
    func saveMovies(_ movies: [MovieData]) -> Bool {
        let url = documentsDirectory.appendingPathComponent(moviesFileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(movies)
            try data.write(to: url)
            
            logger.info("📂 ✅ Saved \(movies.count) movies to file storage")
            return true
        } catch {
            logger.error("📂 ❌ Failed to save movies: \(error)")
            return false
        }
    }
    
    func loadMovies() -> [MovieData] {
        let url = documentsDirectory.appendingPathComponent(moviesFileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            logger.info("📂 No movies file found, returning empty array")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let movies = try decoder.decode([MovieData].self, from: data)
            logger.info("📂 ✅ Loaded \(movies.count) movies from file storage")
            return movies
        } catch {
            logger.error("📂 ❌ Failed to load movies: \(error)")
            return []
        }
    }
    
    // MARK: - Watchlist Storage (Lightweight UserDefaults)
    
    func saveWatchlist(_ watchlist: [UUID]) -> Bool {
        // Use UserDefaults only for the UUID array (much smaller)
        do {
            let data = try JSONEncoder().encode(watchlist)
            UserDefaults.standard.set(data, forKey: "watchlist_v2")
            
            // Also save to file as backup
            let url = documentsDirectory.appendingPathComponent(watchlistFileName)
            try data.write(to: url)
            
            logger.info("📂 ✅ Saved watchlist with \(watchlist.count) items")
            return true
        } catch {
            logger.error("📂 ❌ Failed to save watchlist: \(error)")
            return false
        }
    }
    
    func loadWatchlist() -> [UUID] {
        // Try UserDefaults first
        if let data = UserDefaults.standard.data(forKey: "watchlist_v2") {
            do {
                let watchlist = try JSONDecoder().decode([UUID].self, from: data)
                logger.info("📂 ✅ Loaded watchlist from UserDefaults: \(watchlist.count) items")
                return watchlist
            } catch {
                logger.error("📂 ❌ Failed to decode watchlist from UserDefaults: \(error)")
            }
        }
        
        // Fallback to file storage
        let url = documentsDirectory.appendingPathComponent(watchlistFileName)
        guard FileManager.default.fileExists(atPath: url.path) else {
            logger.info("📂 No watchlist found, returning empty array")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let watchlist = try JSONDecoder().decode([UUID].self, from: data)
            logger.info("📂 ✅ Loaded watchlist from file backup: \(watchlist.count) items")
            return watchlist
        } catch {
            logger.error("📂 ❌ Failed to load watchlist backup: \(error)")
            return []
        }
    }
    
    // MARK: - Watched Movies Storage
    
    func saveWatchedMovies(_ watchedMovies: [UUID: Date]) -> Bool {
        let url = documentsDirectory.appendingPathComponent(watchedMoviesFileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(watchedMovies)
            try data.write(to: url)
            
            logger.info("📂 ✅ Saved watched movies: \(watchedMovies.count) items")
            return true
        } catch {
            logger.error("📂 ❌ Failed to save watched movies: \(error)")
            return false
        }
    }
    
    func loadWatchedMovies() -> [UUID: Date] {
        let url = documentsDirectory.appendingPathComponent(watchedMoviesFileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            logger.info("📂 No watched movies file found, returning empty dictionary")
            return [:]
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let watchedMovies = try decoder.decode([UUID: Date].self, from: data)
            logger.info("📂 ✅ Loaded watched movies: \(watchedMovies.count) items")
            return watchedMovies
        } catch {
            logger.error("📂 ❌ Failed to load watched movies: \(error)")
            return [:]
        }
    }
    
    // MARK: - Migration & Cleanup
    
    func migrateFromUserDefaults() {
        logger.info("🔄 Starting migration from UserDefaults to file storage...")
        
        // Try to migrate old watchlist data
        if let oldData = UserDefaults.standard.data(forKey: "stored_watchlist") {
            do {
                let oldWatchlist = try JSONDecoder().decode([UUID].self, from: oldData)
                logger.info("🔄 Found old watchlist with \(oldWatchlist.count) items - migrating...")
                _ = saveWatchlist(oldWatchlist)
            } catch {
                logger.error("🔄 Failed to migrate old watchlist: \(error)")
            }
        }
        
        // Try to migrate old watched movies
        if let oldData = UserDefaults.standard.data(forKey: "stored_watched_movies") {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let oldWatchedMovies = try decoder.decode([UUID: Date].self, from: oldData)
                logger.info("🔄 Found old watched movies with \(oldWatchedMovies.count) items - migrating...")
                _ = saveWatchedMovies(oldWatchedMovies)
            } catch {
                logger.error("🔄 Failed to migrate old watched movies: \(error)")
            }
        }
        
        // Clean up old UserDefaults to free space
        let keysToRemove = [
            "stored_watchlist",
            "stored_watched_movies",
            "movies_data",
            "all_movies"
        ]
        
        for key in keysToRemove {
            if UserDefaults.standard.object(forKey: key) != nil {
                logger.info("🧹 Removing old UserDefaults key: \(key)")
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        
        UserDefaults.standard.synchronize()
        logger.info("🔄 ✅ Migration completed - UserDefaults cleaned up")
    }
    
    func getStorageInfo() -> String {
        let urls = [
            documentsDirectory.appendingPathComponent(moviesFileName),
            documentsDirectory.appendingPathComponent(watchlistFileName),
            documentsDirectory.appendingPathComponent(watchedMoviesFileName)
        ]
        
        var info = "📂 Storage Info:\n"
        var totalSize: Int64 = 0
        
        for url in urls {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    let size = attributes[.size] as? Int64 ?? 0
                    totalSize += size
                    
                    let sizeString = ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
                    info += "  \(url.lastPathComponent): \(sizeString)\n"
                } catch {
                    info += "  \(url.lastPathComponent): Error reading size\n"
                }
            } else {
                info += "  \(url.lastPathComponent): Not found\n"
            }
        }
        
        let totalSizeString = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
        info += "  Total: \(totalSizeString)"
        
        return info
    }
}

// MARK: - Enhanced Movie Data Provider
class EnhancedMovieDataProvider: MovieDataProviderProtocol {
    
    private let fileManager = EnhancedFileManager()
    private let logger = Logger(subsystem: "com.heykidswatchthis.app", category: "DataProvider")
    
    init() {
        // Perform migration on first run
        fileManager.migrateFromUserDefaults()
        
        // Initialize with sample data if no movies exist
        if loadMovies().isEmpty {
            let sampleMovies = createSampleMovies()
            _ = fileManager.saveMovies(sampleMovies)
            logger.info("🎬 Initialized with \(sampleMovies.count) sample movies")
        }
    }
    
    func loadMovies() -> [MovieData] {
        return fileManager.loadMovies()
    }
    
    func saveMovies(_ movies: [MovieData]) -> Bool {
        return fileManager.saveMovies(movies)
    }
    
    func loadWatchlist() -> [UUID] {
        return fileManager.loadWatchlist()
    }
    
    func saveWatchlist(_ watchlist: [UUID]) {
        _ = fileManager.saveWatchlist(watchlist)
    }
    
    func loadWatchedMovies() -> [UUID: Date] {
        return fileManager.loadWatchedMovies()
    }
    
    func saveWatchedMovies(_ watchedMovies: [UUID: Date]) {
        _ = fileManager.saveWatchedMovies(watchedMovies)
    }
    
    // MARK: - Debug Information
    
    func getDebugInfo() -> String {
        var info = "🔍 Enhanced Data Provider Debug Info:\n"
        info += "Movies: \(loadMovies().count)\n"
        info += "Watchlist: \(loadWatchlist().count)\n"
        info += "Watched: \(loadWatchedMovies().count)\n"
        info += "\n"
        info += fileManager.getStorageInfo()
        return info
    }
    
    // MARK: - Sample Movies (Essential Set)
    
    private func createSampleMovies() -> [MovieData] {
        return [
            MovieData(
                id: UUID(),
                title: "My Neighbor Totoro",
                year: 1988,
                ageGroup: .preschoolers,
                genre: "Fantasy Animation",
                emoji: "🌳",
                streamingServices: ["Max", "Hulu"],
                rating: 4.8,
                notes: "Miyazaki's gentle masterpiece about sisters discovering forest spirits."
            ),
            MovieData(
                id: UUID(),
                title: "The Iron Giant",
                year: 1999,
                ageGroup: .bigKids,
                genre: "Sci-Fi Animation",
                emoji: "🤖",
                streamingServices: ["Max", "Amazon Prime Video"],
                rating: 4.8,
                notes: "Brad Bird's masterpiece about friendship, choice, and heroism."
            ),
            MovieData(
                id: UUID(),
                title: "Finding Nemo",
                year: 2003,
                ageGroup: .littleKids,
                genre: "Adventure Animation",
                emoji: "🐠",
                streamingServices: ["Disney+"],
                rating: 4.6,
                notes: "Pixar's underwater adventure about family and perseverance."
            ),
            MovieData(
                id: UUID(),
                title: "Spirited Away",
                year: 2001,
                ageGroup: .tweens,
                genre: "Fantasy Animation",
                emoji: "🏮",
                streamingServices: ["Max", "Netflix"],
                rating: 4.9,
                notes: "Miyazaki's masterpiece about courage, resilience, and finding yourself."
            ),
            MovieData(
                id: UUID(),
                title: "Coco",
                year: 2017,
                ageGroup: .bigKids,
                genre: "Musical Animation",
                emoji: "💀",
                streamingServices: ["Disney+"],
                rating: 4.8,
                notes: "Beautiful celebration of Mexican culture, family, and following dreams."
            ),
            MovieData(
                id: UUID(),
                title: "WALL-E",
                year: 2008,
                ageGroup: .bigKids,
                genre: "Sci-Fi Animation",
                emoji: "🤖",
                streamingServices: ["Disney+"],
                rating: 4.8,
                notes: "Pixar's environmental love story told with minimal dialogue."
            ),
            MovieData(
                id: UUID(),
                title: "Inside Out",
                year: 2015,
                ageGroup: .bigKids,
                genre: "Comedy Drama",
                emoji: "🧠",
                streamingServices: ["Disney+"],
                rating: 4.6,
                notes: "Pixar's brilliant exploration of emotions and growing up."
            ),
            MovieData(
                id: UUID(),
                title: "Mermaid",
                year: 1997,
                ageGroup: .preschoolers,
                genre: "Animation Short",
                emoji: "🧜‍♀️",
                streamingServices: ["Educational platforms"],
                rating: 4.0,
                notes: "Beautiful short animation about underwater fantasy."
            ),
            MovieData(
                id: UUID(),
                title: "The Secret of Kells",
                year: 2009,
                ageGroup: .littleKids,
                genre: "Fantasy Animation",
                emoji: "📜",
                streamingServices: ["Netflix", "Amazon Prime Video"],
                rating: 4.3,
                notes: "Irish animated masterpiece with stunning Celtic art style."
            ),
            MovieData(
                id: UUID(),
                title: "Ernest & Celestine",
                year: 2012,
                ageGroup: .littleKids,
                genre: "Animation",
                emoji: "🐻",
                streamingServices: ["Netflix", "Amazon Prime Video"],
                rating: 4.4,
                notes: "French animation about unlikely friendship between bear and mouse."
            )
        ]
    }
}
