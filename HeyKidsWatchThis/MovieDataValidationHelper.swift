//
//  MovieDataValidationHelper.swift
//  HeyKidsWatchThis
//
//  TDD REFACTOR PHASE: Data validation utilities to prevent future issues
//

import Foundation

/// Helper class for validating movie data integrity
struct MovieDataValidationHelper {
    
    // MARK: - Validation Results
    
    struct ValidationResult {
        let isValid: Bool
        let errors: [String]
        
        static let valid = ValidationResult(isValid: true, errors: [])
        
        static func invalid(_ errors: [String]) -> ValidationResult {
            return ValidationResult(isValid: false, errors: errors)
        }
    }
    
    // MARK: - Core Validation Methods
    
    /// Validates a single movie entry for data integrity
    static func validateMovie(_ movie: MovieData) -> ValidationResult {
        var errors: [String] = []
        
        // Basic field validation
        if movie.title.isEmpty {
            errors.append("Title cannot be empty")
        }
        
        if movie.year < 1900 || movie.year > 2025 {
            errors.append("Year \(movie.year) is outside reasonable range (1900-2025)")
        }
        
        if movie.emoji.isEmpty {
            errors.append("Emoji cannot be empty")
        }
        
        if movie.streamingServices.isEmpty {
            errors.append("Must have at least one streaming service")
        }
        
        // Rating validation
        if let rating = movie.rating {
            if rating < 0.0 || rating > 5.0 {
                errors.append("Rating \(rating) must be between 0.0 and 5.0")
            }
        }
        
        // Age group appropriateness
        if let ageError = validateAgeGroupAppropriate(movie) {
            errors.append(ageError)
        }
        
        // Streaming service validation
        if let streamingError = validateStreamingServices(movie) {
            errors.append(streamingError)
        }
        
        return errors.isEmpty ? .valid : .invalid(errors)
    }
    
    /// Validates a collection of movies for duplicates and consistency
    static func validateMovieCollection(_ movies: [MovieData]) -> ValidationResult {
        var errors: [String] = []
        
        // Check for duplicates
        let duplicates = findDuplicateMovies(movies)
        if !duplicates.isEmpty {
            errors.append("Duplicate movies found: \(duplicates.joined(separator: ", "))")
        }
        
        // Validate each individual movie
        for movie in movies {
            let movieValidation = validateMovie(movie)
            if !movieValidation.isValid {
                errors.append("Movie '\(movie.title)' (\(movie.year)): \(movieValidation.errors.joined(separator: ", "))")
            }
        }
        
        return errors.isEmpty ? .valid : .invalid(errors)
    }
    
    // MARK: - Specific Validation Helpers
    
    private static func validateAgeGroupAppropriate(_ movie: MovieData) -> String? {
        guard let notes = movie.notes else { return nil }
        
        let matureKeywords = ["war", "death", "violence", "existential", "philosophical", "mature themes"]
        let hasMatureContent = matureKeywords.contains { notes.lowercased().contains($0) }
        
        if hasMatureContent && movie.ageGroup == .preschoolers {
            return "Movie has mature content but is classified for preschoolers"
        }
        
        return nil
    }
    
    private static func validateStreamingServices(_ movie: MovieData) -> String? {
        let validServices = [
            "Disney+", "Netflix", "Amazon Prime Video", "Hulu", "Max",
            "Criterion Channel", "YouTube", "Archive.org", "Peacock",
            "Paramount+", "Apple TV+", "Educational platforms", "Pluto TV",
            "Crunchyroll", "Funimation", "Tubi", "Vimeo"
        ]
        
        let invalidServices = movie.streamingServices.filter { !validServices.contains($0) }
        
        if !invalidServices.isEmpty {
            return "Invalid streaming services: \(invalidServices.joined(separator: ", "))"
        }
        
        return nil
    }
    
    private static func findDuplicateMovies(_ movies: [MovieData]) -> [String] {
        var seenMovies: Set<String> = []
        var duplicates: [String] = []
        
        for movie in movies {
            let movieKey = "\(movie.title) (\(movie.year))"
            if seenMovies.contains(movieKey) {
                if !duplicates.contains(movieKey) {
                    duplicates.append(movieKey)
                }
            } else {
                seenMovies.insert(movieKey)
            }
        }
        
        return duplicates
    }
    
    // MARK: - Specific Movie Validation
    
    /// Validates specific movies that have known correct data
    static func validateSpecificMovies(_ movies: [MovieData]) -> ValidationResult {
        var errors: [String] = []
        
        // Validate SOUL (2020) specifically
        if let soulValidation = validateSoulMovie(movies) {
            errors.append(soulValidation)
        }
        
        return errors.isEmpty ? .valid : .invalid(errors)
    }
    
    private static func validateSoulMovie(_ movies: [MovieData]) -> String? {
        let soulMovies = movies.filter { $0.title == "Soul" && $0.year == 2020 }
        
        if soulMovies.count != 1 {
            return "Expected exactly one SOUL (2020) movie, found \(soulMovies.count)"
        }
        
        guard let soul = soulMovies.first else { return nil }
        
        // Validate SOUL-specific requirements
        if soul.ageGroup != .tweens {
            return "SOUL should be classified as .tweens due to philosophical themes"
        }
        
        if soul.emoji != "🎷" {
            return "SOUL should use jazz saxophone emoji '🎷'"
        }
        
        if !soul.streamingServices.contains("Disney+") {
            return "SOUL should be available on Disney+ (Pixar film)"
        }
        
        if let notes = soul.notes {
            if notes.lowercased().contains("chinese mythology") {
                return "SOUL should not contain 'Over the Moon' description"
            }
            
            if !notes.lowercased().contains("jazz") && !notes.lowercased().contains("music") {
                return "SOUL should reference jazz or music in description"
            }
        }
        
        return nil
    }
}

// MARK: - Extension for MovieDataProvider Integration

extension MovieDataProvider {
    
    /// Validates all movies in the data provider
    func validateAllMovies() -> MovieDataValidationHelper.ValidationResult {
        let movies = loadMovies()
        return MovieDataValidationHelper.validateMovieCollection(movies)
    }
    
    /// Validates specific high-profile movies
    func validateSpecialMovies() -> MovieDataValidationHelper.ValidationResult {
        let movies = loadMovies()
        return MovieDataValidationHelper.validateSpecificMovies(movies)
    }
}
