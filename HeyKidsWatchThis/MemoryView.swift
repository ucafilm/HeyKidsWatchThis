// MemoryView.swift - FIXED: Proper deleteMemory result handling
// Following TDD + RAG + Context7 methodology with actor isolation compliance

import SwiftUI

struct MemoryView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    // Use environment to get services
    private var memoryService: MemoryServiceProtocol {
        navigationManager.memoryService
    }
    
    private var movieService: MovieServiceProtocol {
        navigationManager.movieService
    }
    
    @State private var memories: [MemoryData] = []
    @State private var showingCreateMemory = false
    @State private var showingDeleteAlert = false
    @State private var memoryToDelete: MemoryData?
    
    var body: some View {
        NavigationStack {
            Group {
                if memories.isEmpty {
                    ContentUnavailableView {
                        Label("No Memories", systemImage: "photo.on.rectangle")
                    } description: {
                        Text("Create memories of your family movie nights!")
                    } actions: {
                        Button("Create Memory") {
                            showingCreateMemory = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(memories) { memory in
                            MemoryRowView(memory: memory, movieService: movieService)
                        }
                        .onDelete(perform: deleteMemories)
                    }
                }
            }
            .navigationTitle("Memories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateMemory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateMemory) {
                CreateMemoryView()
                    .environmentObject(navigationManager)
            }
            .alert("Delete Memory", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let memory = memoryToDelete {
                        performDelete(memory)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this memory? This action cannot be undone.")
            }
            .onAppear {
                loadMemories()
            }
        }
    }
    
    private func loadMemories() {
        memories = memoryService.getAllMemories()
    }
    
    private func deleteMemories(offsets: IndexSet) {
        for index in offsets {
            let memory = memories[index]
            memoryToDelete = memory
            showingDeleteAlert = true
            return // Only delete one at a time for better UX
        }
    }
    
    // FIXED: Proper result handling for deleteMemory
    private func performDelete(_ memory: MemoryData) {
        let success = memoryService.deleteMemory(memory.id)
        
        if success {
            // Remove from local array for immediate UI update
            memories.removeAll { $0.id == memory.id }
            
            // Provide user feedback
            HapticFeedbackManager.shared.triggerSuccess()
            
            // Reload to ensure consistency
            loadMemories()
        } else {
            // Handle deletion failure
            HapticFeedbackManager.shared.triggerError()
            
            // Could show an error alert here if needed
            print("⚠️ Failed to delete memory: \(memory.id)")
        }
        
        // Clear the memory to delete
        memoryToDelete = nil
    }
}

struct MemoryRowView: View {
    let memory: MemoryData
    let movieService: MovieServiceProtocol
    
    private var movie: MovieData? {
        movieService.getMovie(by: memory.movieId)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // NEW: Photo thumbnail preview or movie emoji
            Group {
                if let firstPhoto = memory.photos.first,
                   let uiImage = firstPhoto.optimizedUIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    // Movie emoji fallback
                    Text(movie?.emoji ?? "🎬")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(movie?.title ?? "Unknown Movie")
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= memory.rating ? "star.fill" : "star")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                }
                
                HStack {
                    Text(memory.watchDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Photo count indicator
                    if !memory.photos.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "photo")
                                .font(.caption2)
                            Text("\(memory.photos.count)")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Discussion indicator
                    if !memory.discussionAnswers.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.caption2)
                            Text("\(memory.discussionAnswers.count)")
                                .font(.caption2)
                        }
                        .foregroundColor(.green)
                    }
                }
                
                if let notes = memory.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

/*
 ACTOR ISOLATION & ERROR HANDLING FIXES:
 
 1. Unused Result Warning Fixed:
    - deleteMemory() result is now properly captured and handled
    - Success/failure paths provide appropriate user feedback
    - Haptic feedback for user experience enhancement
    
 2. Enhanced UX:
    - Added confirmation alert for delete operations
    - Immediate UI update on successful deletion
    - Error handling for failed deletions
    - One-at-a-time deletion for better control
    
 3. Actor Isolation Compliance:
    - All UI operations remain on MainActor
    - Service calls properly handled
    - No actor isolation violations
    
 4. Error Recovery:
    - Failed deletions don't crash the app
    - User feedback through haptics and console logging
    - State consistency maintained through reload
 */
