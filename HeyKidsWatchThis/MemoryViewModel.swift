// MemoryViewModel.swift - FIXED: Made services publicly accessible
// HeyKidsWatchThis - Memory View Model
// Following established @Observable MovieListViewModel patterns with proper DI

import SwiftUI

@Observable
class MemoryViewModel {
    
    // MARK: - Published Properties (following MovieListViewModel pattern)
    
    private(set) var memories: [MemoryData] = []
    private(set) var filteredMemories: [MemoryData] = []
    private(set) var isLoading = false
    
    // Filter properties
    var selectedAgeGroup: AgeGroup?
    var searchText: String = "" {
        didSet {
            applyFilters()
        }
    }
    var selectedMovieId: UUID?
    var minimumRating: Int = 1
    
    // MARK: - Computed Properties
    
    var hasActiveFilters: Bool {
        return selectedAgeGroup != nil ||
               !searchText.isEmpty ||
               selectedMovieId != nil ||
               minimumRating > 1
    }
    
    var memoryCount: Int {
        return memories.count
    }
    
    // MARK: - Dependencies (FIXED: Made public for proper dependency injection)
    
    let memoryService: MemoryServiceProtocol  // Made public, not private
    let movieService: MovieServiceProtocol    // Made public, not private
    let photoService: PhotoMemoryServiceProtocol  // NEW: Photo service integration
    
    // MARK: - Photo Loading State
    
    private(set) var isLoadingPhotos = false
    
    // MARK: - Initialization
    
    init(
        memoryService: MemoryServiceProtocol, 
        movieService: MovieServiceProtocol,
        photoService: PhotoMemoryServiceProtocol = PhotoMemoryService()
    ) {
        self.memoryService = memoryService
        self.movieService = movieService
        self.photoService = photoService
        loadMemories()
    }
    
    // MARK: - Memory Operations
    
    func loadMemories() {
        isLoading = true
        
        // Simulate brief loading for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.memories = self.memoryService.getAllMemories()
            self.applyFilters()
            self.isLoading = false
        }
    }
    
    // NEW: Enhanced memory loading with photos
    @MainActor
    func loadMemoriesWithPhotos() async {
        isLoading = true
        isLoadingPhotos = true
        
        // Load base memories
        let baseMemories = memoryService.getAllMemories()
        
        // Load photos for each memory
        var memoriesWithPhotos: [MemoryData] = []
        for memory in baseMemories {
            let photos = photoService.loadPhotos(for: memory.id)
            let enhancedMemory = MemoryData(
                id: memory.id,
                movieId: memory.movieId,
                watchDate: memory.watchDate,
                rating: memory.rating,
                notes: memory.notes,
                discussionAnswers: memory.discussionAnswers,
                photos: photos
            )
            memoriesWithPhotos.append(enhancedMemory)
        }
        
        self.memories = memoriesWithPhotos
        self.applyFilters()
        self.isLoading = false
        self.isLoadingPhotos = false
    }
    
    func createMemory(for movie: MovieData, rating: Int, notes: String?, watchDate: Date = Date()) -> Bool {
        let memory = MemoryData(
            movieId: movie.id,
            watchDate: watchDate,
            rating: rating,
            notes: notes
        )
        
        let success = memoryService.createMemory(memory)
        if success {
            loadMemories() // Refresh list
        }
        return success
    }
    
    func deleteMemory(_ memory: MemoryData) {
        let success = memoryService.deleteMemory(memory.id)
        if success {
            loadMemories() // Refresh list
        }
    }
    
    func getMovie(for memory: MemoryData) -> MovieData? {
        return movieService.getMovie(by: memory.movieId)
    }
    
    // MARK: - Filtering (following MovieListViewModel pattern)
    
    func clearAllFilters() {
        selectedAgeGroup = nil
        searchText = ""
        selectedMovieId = nil
        minimumRating = 1
        applyFilters()
    }
    
    private func applyFilters() {
        var filtered = memories
        
        // Apply age group filter (through movie)
        if let ageGroup = selectedAgeGroup {
            filtered = filtered.filter { memory in
                guard let movie = movieService.getMovie(by: memory.movieId) else { return false }
                return movie.ageGroup == ageGroup
            }
        }
        
        // Apply movie filter
        if let movieId = selectedMovieId {
            filtered = filtered.filter { $0.movieId == movieId }
        }
        
        // Apply rating filter
        if minimumRating > 1 {
            filtered = filtered.filter { $0.rating >= minimumRating }
        }
        
        // Apply search text
        if !searchText.isEmpty {
            let lowercaseQuery = searchText.lowercased()
            filtered = filtered.filter { memory in
                // Search in notes
                if memory.notes?.lowercased().contains(lowercaseQuery) == true {
                    return true
                }
                
                // Search in discussion answers
                if memory.discussionAnswers.contains(where: { $0.response.lowercased().contains(lowercaseQuery) }) {
                    return true
                }
                
                // Search in movie title
                if let movie = movieService.getMovie(by: memory.movieId),
                   movie.title.lowercased().contains(lowercaseQuery) {
                    return true
                }
                
                return false
            }
        }
        
        filteredMemories = filtered
    }
    
    // MARK: - Memory Statistics
    
    func getAverageRating() -> Double {
        guard !memories.isEmpty else { return 0.0 }
        let total = memories.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(memories.count)
    }
    
    func getMemoryCountFor(ageGroup: AgeGroup) -> Int {
        return memories.filter { memory in
            guard let movie = movieService.getMovie(by: memory.movieId) else { return false }
            return movie.ageGroup == ageGroup
        }.count
    }
    
    func getRecentMemories(limit: Int = 5) -> [MemoryData] {
        return Array(memories.prefix(limit))
    }
    
    // MARK: - Discussion Support
    
    func addDiscussionAnswer(_ answer: DiscussionAnswer, to memory: MemoryData) -> Bool {
        let success = memoryService.saveDiscussionAnswer(answer, for: memory.id)
        if success {
            loadMemories() // Refresh to get updated memory with answer
        }
        return success
    }
    
    func getDiscussionAnswers(for memory: MemoryData) -> [DiscussionAnswer] {
        return memoryService.getDiscussionAnswers(for: memory.id)
    }
    
    // MARK: - Photo Management
    
    func removePhotoFromMemory(_ photo: MemoryPhoto, from memory: MemoryData) {
        // Remove photo from PhotoMemoryService
        let deleteResult = photoService.deletePhoto(photo.id, for: memory.id)
        
        if case .success = deleteResult {
            // Update local memory data by reloading
            Task {
                await loadMemoriesWithPhotos()
            }
        }
    }
    
    func addPhotosToMemory(_ photos: [MemoryPhoto], to memory: MemoryData) {
        // Save each photo using PhotoMemoryService
        for photo in photos {
            _ = photoService.savePhoto(photo, for: memory.id)
        }
        
        // Reload memories to include new photos
        Task {
            await loadMemoriesWithPhotos()
        }
    }
}
