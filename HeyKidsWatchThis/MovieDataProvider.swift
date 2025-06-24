// MovieDataProvider.swift
// HeyKidsWatchThis - DEFINITIVE FIX: Watchlist persistence
// NO MORE CLEARING - This version preserves watchlist data

import Foundation

/// Movie data provider using UserDefaults following established patterns
class MovieDataProvider: MovieDataProviderProtocol {
    
    private let userDefaults: UserDefaults
    private let watchlistKey = "stored_watchlist"
    private let watchedMoviesKey = "stored_watched_movies"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        print("🏗️ MovieDataProvider initialized with key: \(watchlistKey)")
    }
    
    // SURGICAL FIX: Move large movie data to file storage to prevent 4MB UserDefaults limit
    func loadMovies() -> [MovieData] {
        // Try loading from file storage first
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let moviesURL = documentsURL.appendingPathComponent("movies.json")
        
        if FileManager.default.fileExists(atPath: moviesURL.path) {
            do {
                let data = try Data(contentsOf: moviesURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let movies = try decoder.decode([MovieData].self, from: data)
                print("📂 Loaded \(movies.count) movies from file storage")
                
                // If we have a small collection, replace it with the full collection
                if movies.count < 50 {
                    print("🔄 Small collection detected (\(movies.count)), replacing with full collection")
                    let fullMovies = createSampleMovies()
                    saveMoviesToFile(fullMovies)
                    return fullMovies
                }
                
                return movies
            } catch {
                print("⚠️ Failed to load movies from file: \(error)")
            }
        }
        
        // If no file exists, create and save full movie collection
        let fullMovies = createSampleMovies()
        saveMoviesToFile(fullMovies)
        return fullMovies
    }
    
    // Helper to save movies to file storage
    private func saveMoviesToFile(_ movies: [MovieData]) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let moviesURL = documentsURL.appendingPathComponent("movies.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(movies)
            try data.write(to: moviesURL)
            print("📂 Saved \(movies.count) movies to file storage")
        } catch {
            print("⚠️ Failed to save movies to file: \(error)")
        }
    }
    
    // DEFINITIVE FIX: NEVER clear watchlist data - always preserve it
    func loadWatchlist() -> [UUID] {
        print("🔍 MovieDataProvider.loadWatchlist() called - PRESERVING existing data")
        
        // Try to load existing watchlist data
        guard let data = userDefaults.data(forKey: watchlistKey) else {
            print("📂 No existing watchlist found - starting with empty watchlist")
            return []
        }
        
        do {
            let watchlist = try JSONDecoder().decode([UUID].self, from: data)
            print("📂 ✅ PRESERVED existing watchlist with \(watchlist.count) items")
            print("📂 Watchlist IDs: \(watchlist.prefix(3))")
            return watchlist
        } catch {
            print("⚠️ Failed to decode watchlist: \(error) - starting fresh")
            return []
        }
    }
    
    func saveWatchlist(_ watchlist: [UUID]) {
        print("💾 MovieDataProvider.saveWatchlist() called with \(watchlist.count) items")
        
        do {
            let data = try JSONEncoder().encode(watchlist)
            userDefaults.set(data, forKey: watchlistKey)
            userDefaults.synchronize() // Force immediate save
            print("💾 ✅ SAVED watchlist with \(watchlist.count) items to key: \(watchlistKey)")
        } catch {
            print("⚠️ Failed to save watchlist: \(error)")
        }
    }
    
    func loadWatchedMovies() -> [UUID: Date] {
        guard let data = userDefaults.data(forKey: watchedMoviesKey) else { return [:] }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([UUID: Date].self, from: data)
        } catch {
            print("Failed to load watched movies: \(error)")
            return [:]
        }
    }
    
    func saveWatchedMovies(_ watchedMovies: [UUID: Date]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(watchedMovies)
            userDefaults.set(data, forKey: watchedMoviesKey)
            userDefaults.synchronize() // Force immediate save
        } catch {
            print("Failed to save watched movies: \(error)")
        }
    }
    
    // MARK: - Sample Data with FIXED UUIDs
    
    private func createSampleMovies() -> [MovieData] {
        // ✅ FIXED UUIDs - These will NEVER change, ensuring watchlist consistency
        return [
            // CORE ESSENTIALS (30 movies with fixed UUIDs)
            MovieData(
                id: UUID(uuidString: "663946EA-E5AD-4CD8-B178-616B865D1775")!,
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
                id: UUID(uuidString: "38AC3F32-9069-4490-A03B-5B64FBD9AB04")!,
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
                id: UUID(uuidString: "7017FB54-3A05-40D0-97A2-1D8666B70DA5")!,
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
                id: UUID(uuidString: "1415487D-3379-456E-A081-374FF1B25935")!,
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
                id: UUID(uuidString: "0A8D00BC-0AEA-45C4-BFEC-FA9E15F31752")!,
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
                id: UUID(uuidString: "4A1E8206-4E7F-494E-A95B-048F6AA7B455")!,
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
                id: UUID(uuidString: "6EAD3BCB-DDE8-476D-B91F-8CE3B3D61F13")!,
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
                id: UUID(uuidString: "F4F6C724-A60E-4585-BC48-F66A072CD983")!,
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
                id: UUID(uuidString: "6DF38BE1-75A9-4692-8511-4783D1DAA93C")!,
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
                id: UUID(uuidString: "83A16079-8D52-49CF-94E7-5092889C36D5")!,
                title: "Ernest & Celestine",
                year: 2012,
                ageGroup: .littleKids,
                genre: "Animation",
                emoji: "🐻",
                streamingServices: ["Netflix", "Amazon Prime Video"],
                rating: 4.4,
                notes: "French animation about unlikely friendship between bear and mouse."
            ),
            MovieData(
                id: UUID(uuidString: "7DBE4404-48F4-438E-A7E1-762499C37690")!,
                title: "Ratatouille",
                year: 2007,
                ageGroup: .littleKids,
                genre: "Comedy Animation",
                emoji: "🐀",
                streamingServices: ["Disney+"],
                rating: 4.7,
                notes: "Pixar's masterpiece about a rat who dreams of becoming a chef."
            ),
            MovieData(
                id: UUID(uuidString: "D7F60AC0-FC68-480E-BC71-0C2DBFDD8FFE")!,
                title: "Kiki's Delivery Service",
                year: 1989,
                ageGroup: .littleKids,
                genre: "Fantasy Animation",
                emoji: "🧙‍♀️",
                streamingServices: ["Max", "Netflix"],
                rating: 4.4,
                notes: "Miyazaki's coming-of-age story about a young witch."
            ),
            MovieData(
                id: UUID(uuidString: "F33A046C-8D26-439B-BD63-B75F3B66655A")!,
                title: "The Incredibles",
                year: 2004,
                ageGroup: .bigKids,
                genre: "Action Animation",
                emoji: "💪",
                streamingServices: ["Disney+"],
                rating: 4.7,
                notes: "Superhero family learning to work together and embrace uniqueness."
            ),
            MovieData(
                id: UUID(uuidString: "51C0BA15-CFAF-44D4-9F06-A015A2EE7431")!,
                title: "Howl's Moving Castle",
                year: 2004,
                ageGroup: .bigKids,
                genre: "Fantasy Animation",
                emoji: "🏰",
                streamingServices: ["Max", "Netflix"],
                rating: 4.5,
                notes: "Miyazaki's tale of self-acceptance and finding inner beauty."
            ),
            MovieData(
                id: UUID(uuidString: "FB0489DD-C879-45C6-B81C-F13B5F4FF8FD")!,
                title: "Princess Mononoke",
                year: 1997,
                ageGroup: .tweens,
                genre: "Fantasy Drama",
                emoji: "🐺",
                streamingServices: ["Max", "Netflix"],
                rating: 4.7,
                notes: "Environmental epic about balance between nature and civilization."
            ),
            MovieData(
                id: UUID(uuidString: "1F107601-FE62-4F0D-A971-3D3AD2F5190C")!,
                title: "Soul",
                year: 2020,
                ageGroup: .tweens,
                genre: "Animation Drama",
                emoji: "🎷",
                streamingServices: ["Disney+"],
                rating: 4.7,
                notes: "Pixar's philosophical masterpiece about a jazz musician's journey."
            ),
            MovieData(
                id: UUID(uuidString: "C8BF4D65-D359-42D2-AA56-AA3EDCC89282")!,
                title: "Zootopia",
                year: 2016,
                ageGroup: .littleKids,
                genre: "Comedy Adventure",
                emoji: "🐰",
                streamingServices: ["Disney+"],
                rating: 4.5,
                notes: "Disney's smart allegory about prejudice in a buddy cop comedy."
            ),
            MovieData(
                id: UUID(uuidString: "9D2290DC-F90A-4195-92D9-FF7F72F23F76")!,
                title: "Chicken Run",
                year: 2000,
                ageGroup: .littleKids,
                genre: "Comedy Animation",
                emoji: "🐔",
                streamingServices: ["Netflix", "Amazon Prime Video"],
                rating: 4.3,
                notes: "Aardman's clever prison escape comedy."
            ),
            MovieData(
                id: UUID(uuidString: "32C9D49C-FAE3-4983-9B96-BCDD6785B18B")!,
                title: "Song of the Sea",
                year: 2014,
                ageGroup: .littleKids,
                genre: "Fantasy Animation",
                emoji: "🌊",
                streamingServices: ["Netflix", "Amazon Prime Video"],
                rating: 4.5,
                notes: "Irish folklore brought to life with stunning hand-drawn animation."
            ),
            MovieData(
                id: UUID(uuidString: "40AC6543-D0CA-473A-9ADB-26D651209091")!,
                title: "Kubo and the Two Strings",
                year: 2016,
                ageGroup: .bigKids,
                genre: "Adventure Animation",
                emoji: "🎸",
                streamingServices: ["Netflix", "Amazon Prime Video"],
                rating: 4.4,
                notes: "Laika's stop-motion masterpiece about storytelling and family."
            ),
            MovieData(
                id: UUID(uuidString: "97270C5E-9E45-45D8-B518-E091DCAB4AE2")!,
                title: "The Red Balloon",
                year: 1956,
                ageGroup: .preschoolers,
                genre: "Fantasy Short",
                emoji: "🎈",
                streamingServices: ["Max", "Criterion Channel"],
                rating: 4.5,
                notes: "Albert Lamorisse's wordless wonder - pure visual storytelling."
            ),
            MovieData(
                id: UUID(uuidString: "7857AB79-31F8-4DCF-BD26-677A6B9C6018")!,
                title: "Fantastic Mr. Fox",
                year: 2009,
                ageGroup: .preschoolers,
                genre: "Stop-Motion Comedy",
                emoji: "🦊",
                streamingServices: ["Disney+", "Hulu"],
                rating: 4.6,
                notes: "Wes Anderson's charming Roald Dahl adaptation."
            ),
            MovieData(
                id: UUID(uuidString: "ABCE7D8F-325A-4AD9-9F32-C29FE33782D6")!,
                title: "The Little Prince",
                year: 2015,
                ageGroup: .bigKids,
                genre: "Fantasy Animation",
                emoji: "👑",
                streamingServices: ["Netflix"],
                rating: 4.2,
                notes: "Beautiful adaptation mixing stop-motion and CGI storytelling."
            ),
            MovieData(
                id: UUID(uuidString: "5D68336E-22C8-4E18-A608-0E3E9BAC6823")!,
                title: "The Breadwinner",
                year: 2017,
                ageGroup: .tweens,
                genre: "Drama Animation",
                emoji: "📚",
                streamingServices: ["Netflix"],
                rating: 4.5,
                notes: "Powerful story about resilience and education in Afghanistan."
            ),
            MovieData(
                id: UUID(uuidString: "9EAE2AB5-C614-4562-BFC0-46AD69A1F136")!,
                title: "Your Name",
                year: 2016,
                ageGroup: .tweens,
                genre: "Romance Animation",
                emoji: "⭐",
                streamingServices: ["Crunchyroll", "Funimation"],
                rating: 4.6,
                notes: "Japanese masterpiece about connection across time and space."
            ),
            MovieData(
                id: UUID(uuidString: "08052052-6BDE-42F2-8406-2ACAFABC85DC")!,
                title: "Isle of Dogs",
                year: 2018,
                ageGroup: .tweens,
                genre: "Stop-Motion Comedy",
                emoji: "🐕",
                streamingServices: ["Disney+", "Hulu"],
                rating: 4.3,
                notes: "Wes Anderson's meticulous stop-motion about loyalty and friendship."
            ),
            MovieData(
                id: UUID(uuidString: "8018A611-B0F9-48B9-ADC3-3D29068F8EF8")!,
                title: "Persepolis",
                year: 2007,
                ageGroup: .tweens,
                genre: "Biographical Animation",
                emoji: "📖",
                streamingServices: ["Amazon Prime Video"],
                rating: 4.4,
                notes: "Marjane Satrapi's autobiographical tale of growing up in Iran."
            ),
            MovieData(
                id: UUID(uuidString: "C0E0A248-A292-4E78-82C4-FBC6B2BDD331")!,
                title: "Robin Hood",
                year: 1973,
                ageGroup: .littleKids,
                genre: "Adventure Animation",
                emoji: "🏹",
                streamingServices: ["Disney+"],
                rating: 4.4,
                notes: "Disney's anthropomorphic take on the classic Robin Hood legend."
            ),
            MovieData(
                id: UUID(uuidString: "78AFCE74-8B03-4526-AF80-A64818E43BFF")!,
                title: "The Fox and the Hound",
                year: 1981,
                ageGroup: .preschoolers,
                genre: "Drama Animation",
                emoji: "🐺",
                streamingServices: ["Disney+"],
                rating: 4.2,
                notes: "Disney's thoughtful exploration of friendship across barriers."
            ),
            MovieData(
                id: UUID(uuidString: "14FA495C-99D3-49F1-B1AB-9BAAB7AF80C9")!,
                title: "The Sandlot",
                year: 1993,
                ageGroup: .bigKids,
                genre: "Sports Comedy",
                emoji: "⚾",
                streamingServices: ["Disney+", "Amazon Prime Video"],
                rating: 4.6,
                notes: "Beloved coming-of-age baseball story about summer friendship."
            )
        ]
    }
}
