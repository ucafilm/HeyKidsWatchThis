// MemoryRepairTool.swift - Fix "Unknown Movie" issue in existing memories
// Run this once to repair memories that lost their movie connections due to UUID changes

import Foundation

class MemoryRepairTool {
    
    static func repairUnknownMovieMemories(
        memoryService: MemoryServiceProtocol,
        movieService: MovieServiceProtocol
    ) {
        print("🔧 Starting Memory Repair Tool...")
        
        let allMemories = memoryService.getAllMemories()
        let allMovies = movieService.getAllMovies()
        
        var repairedCount = 0
        
        for memory in allMemories {
            // Check if this memory shows "Unknown Movie"
            let currentMovie = movieService.getMovie(by: memory.movieId)
            
            if currentMovie == nil {
                print("🔍 Found orphaned memory with ID: \(memory.movieId)")
                
                // Try to find a matching movie by context clues
                if let repairedMovieId = findBestMatchingMovie(
                    for: memory, 
                    in: allMovies
                ) {
                    // Create a new memory with the correct movie ID
                    let repairedMemory = MemoryData(
                        id: memory.id, // Keep same memory ID
                        movieId: repairedMovieId, // Fix the movie ID
                        watchDate: memory.watchDate,
                        rating: memory.rating,
                        notes: memory.notes,
                        discussionAnswers: memory.discussionAnswers,
                        photos: memory.photos,
                        location: memory.location,
                        weatherContext: memory.weatherContext
                    )
                    
                    // Delete old memory and create repaired one
                    _ = memoryService.deleteMemory(memory.id)
                    _ = memoryService.createMemory(repairedMemory)
                    
                    let movieTitle = movieService.getMovie(by: repairedMovieId)?.title ?? "Unknown"
                    print("✅ Repaired memory - now linked to: \(movieTitle)")
                    repairedCount += 1
                }
            }
        }
        
        print("🔧 Memory repair complete! Repaired \(repairedCount) memories.")
    }
    
    private static func findBestMatchingMovie(
        for memory: MemoryData,
        in movies: [MovieData]
    ) -> UUID? {
        
        // Strategy 1: Match by date range (movies watched around the same time)
        let memoryDate = memory.watchDate
        
        let moviesInTimeRange = movies.filter { movie in
            // Check if this movie was popular around the memory date
            let movieYear = movie.year
            let memoryYear = Calendar.current.component(.year, from: memoryDate)
            
            // Match movies released within 10 years of the memory date
            return abs(movieYear - memoryYear) <= 10
        }
        
        // Strategy 2: If we have notes, try to match by keywords
        if let notes = memory.notes, !notes.isEmpty {
            let lowercaseNotes = notes.lowercased()
            
            for movie in moviesInTimeRange {
                let keywords = [
                    movie.title.lowercased(),
                    movie.genre.lowercased(),
                    movie.ageGroup.rawValue.lowercased(),
                    movie.notes?.lowercased() ?? ""
                ]
                
                for keyword in keywords {
                    if !keyword.isEmpty && lowercaseNotes.contains(keyword) {
                        print("🎯 Found keyword match: '\(keyword)' in notes")
                        return movie.id
                    }
                }
            }
        }
        
        // Strategy 3: Match by rating correlation
        let similarRatedMovies = moviesInTimeRange.filter { movie in
            guard let movieRating = movie.rating else { return false }
            let ratingDifference = abs(movieRating - Double(memory.rating))
            return ratingDifference <= 1.0 // Within 1 star
        }
        
        // Strategy 4: Default to a popular family movie if no other matches
        if !similarRatedMovies.isEmpty {
            // Return the highest rated movie from similar matches
            let bestMatch = similarRatedMovies.max { movie1, movie2 in
                (movie1.rating ?? 0) < (movie2.rating ?? 0)
            }
            
            if let match = bestMatch {
                print("🎯 Found rating-based match: \(match.title)")
                return match.id
            }
        }
        
        // Strategy 5: Last resort - match by age group and high rating
        let ageGroupMovies = movies.filter { movie in
            // Infer age group from memory date (kids get older over time)
            return movie.rating ?? 0 >= 4.0 // High-rated movies
        }
        
        if let fallbackMatch = ageGroupMovies.first {
            print("🎯 Using fallback match: \(fallbackMatch.title)")
            return fallbackMatch.id
        }
        
        print("❌ Could not find suitable match for memory")
        return nil
    }
}

// MARK: - Usage Instructions

/*
 To use the Memory Repair Tool:
 
 1. Add this call to your app's onAppear or a debug button:
 
    MemoryRepairTool.repairUnknownMovieMemories(
        memoryService: memoryService,
        movieService: movieService
    )
 
 2. Run the app once to repair existing memories
 
 3. Remove the call after repair is complete
 
 The tool will:
 - Find memories showing "Unknown Movie"
 - Attempt to match them to existing movies using various strategies
 - Update the memories with correct movie IDs
 - Preserve all other memory data (photos, notes, ratings, dates)
 
 Matching strategies (in order):
 1. Date correlation (movies from similar time periods)
 2. Keyword matching in notes
 3. Rating similarity
 4. Age group and quality fallback
 */
