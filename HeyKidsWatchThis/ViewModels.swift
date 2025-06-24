// ViewModels.swift - SURGICAL FIX - REMOVED DUPLICATE DiscussionViewModel
// Contains ONLY Extensions and helper ViewModels - no duplicates

import SwiftUI
import Observation

// MARK: - Enhanced Movie List ViewModel Extensions

extension MovieListViewModel {
    
    /// Additional helper methods for enhanced functionality
    func getRecommendationsFor(ageGroup: AgeGroup) -> [MovieData] {
        return filteredMovies.filter { $0.ageGroup == ageGroup }.prefix(5).map { $0 }
    }
    
    /// Performance metrics for debugging
    var performanceMetrics: String {
        return "Movies: \(movies.count), Filtered: \(filteredMovies.count), Filters: \(activeFilterCount)"
    }
}

// MARK: - Memory View Model Extensions

extension MemoryViewModel {
    
    /// Helper methods for memory management
    func getMemoriesForMovie(_ movieId: UUID) -> [MemoryData] {
        return memories.filter { $0.movieId == movieId }
    }
    
    /// Calculate average rating for all memories
    var averageRating: Double {
        guard !memories.isEmpty else { return 0.0 }
        let total = memories.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(memories.count)
    }
}
