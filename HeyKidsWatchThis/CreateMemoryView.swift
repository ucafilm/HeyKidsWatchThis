// CreateMemoryView.swift - ENHANCED WITH PHOTO INTEGRATION
// Following TDD + RAG + Context7 methodology
// GREEN PHASE: Adding PhotosPicker integration

import SwiftUI
import PhotosUI

struct CreateMemoryView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    // Existing state
    @State private var selectedMovie: MovieData?
    @State private var rating: Int = 5
    @State private var notes: String = ""
    @State private var watchDate: Date = Date()
    @State private var showingMoviePicker = false
    
    // NEW: Photo state
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var memoryPhotos: [MemoryPhoto] = []
    @State private var isLoadingPhotos = false
    
    private var memoryService: MemoryServiceProtocol {
        navigationManager.memoryService
    }
    
    private var movieService: MovieServiceProtocol {
        navigationManager.movieService
    }
    
    private var photoService: PhotoMemoryServiceProtocol {
        PhotoMemoryService()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Movie") {
                    Button {
                        showingMoviePicker = true
                    } label: {
                        HStack {
                            Text(selectedMovie?.title ?? "Select Movie")
                                .foregroundColor(selectedMovie == nil ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // NEW: Photos Section
                Section("Photos") {
                    PhotoSelectionSection(
                        selectedItems: $selectedPhotoItems,
                        memoryPhotos: $memoryPhotos,
                        isLoading: $isLoadingPhotos
                    )
                }
                
                Section("Rating") {
                    EnhancedRatingView(rating: $rating)
                }
                
                Section("Notes") {
                    TextField("How was the movie night?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Date") {
                    DatePicker("Watch Date", selection: $watchDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Create Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEnhancedMemory()
                    }
                    .disabled(selectedMovie == nil || isLoadingPhotos)
                }
            }
            .sheet(isPresented: $showingMoviePicker) {
                MoviePickerView(selectedMovie: $selectedMovie)
                    .environmentObject(navigationManager)
            }
            .onChange(of: selectedPhotoItems) { oldItems, newItems in
                loadSelectedPhotos(newItems)
            }
        }
    }
    
    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) {
        isLoadingPhotos = true
        memoryPhotos.removeAll()
        
        Task {
            for item in items {
                do {
                    if let imageData = try await item.loadTransferable(type: Data.self) {
                        let photo = MemoryPhoto(imageData: imageData)
                        await MainActor.run {
                            memoryPhotos.append(photo)
                        }
                    }
                } catch {
                    print("Error loading photo: \(error)")
                }
            }
            
            await MainActor.run {
                isLoadingPhotos = false
            }
        }
    }
    
    private func saveEnhancedMemory() {
        guard let movie = selectedMovie else { return }
        
        let memory = MemoryData(
            movieId: movie.id,
            watchDate: watchDate,
            rating: rating,
            notes: notes.isEmpty ? nil : notes,
            photos: memoryPhotos
        )
        
        // Save memory with photos
        let success = memoryService.createMemory(memory)
        
        if success {
            // Save photos separately using PhotoMemoryService
            for photo in memoryPhotos {
                _ = photoService.savePhoto(photo, for: memory.id)
            }
            
            HapticFeedbackManager.shared.triggerSuccess()
            dismiss()
        } else {
            HapticFeedbackManager.shared.triggerError()
        }
    }
    
    // Legacy save method for backward compatibility
    private func saveMemory() {
        guard let movie = selectedMovie else { return }
        
        let memory = MemoryData(
            movieId: movie.id,
            watchDate: watchDate,
            rating: rating,
            notes: notes.isEmpty ? nil : notes
        )
        
        _ = memoryService.createMemory(memory)
        dismiss()
    }
}

// MARK: - Enhanced Rating View

struct EnhancedRatingView: View {
    @Binding var rating: Int
    @State private var animationTrigger = false
    @State private var selectedStar = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How was the movie?")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        selectRating(star)
                    } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(colorForStar(star))
                            .scaleEffect(star == selectedStar ? 1.3 : 1.0)
                            .symbolEffect(.bounce, value: animationTrigger)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Text(ratingDescription(rating))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: rating)
            }
        }
    }
    
    private func selectRating(_ star: Int) {
        HapticFeedbackManager.shared.triggerImpact(style: .light)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            rating = star
            selectedStar = star
            animationTrigger.toggle()
        }
    }
    
    private func colorForStar(_ star: Int) -> Color {
        switch star {
        case 1: return star <= rating ? .red : .gray
        case 2: return star <= rating ? .orange : .gray
        case 3: return star <= rating ? .yellow : .gray
        case 4: return star <= rating ? .blue : .gray
        case 5: return star <= rating ? .green : .gray
        default: return .gray
        }
    }
    
    private func ratingDescription(_ rating: Int) -> String {
        switch rating {
        case 1: return "Not great"
        case 2: return "Okay"
        case 3: return "Good"
        case 4: return "Great!"
        case 5: return "Amazing!"
        default: return ""
        }
    }
}

// MARK: - Photo Selection Component

struct PhotoSelectionSection: View {
    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var memoryPhotos: [MemoryPhoto]
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Add Photos")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("Select Photos")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading photos...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !memoryPhotos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(memoryPhotos) { photo in
                            PhotoThumbnailView(photo: photo) {
                                removePhoto(photo)
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    private func removePhoto(_ photo: MemoryPhoto) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            memoryPhotos.removeAll { $0.id == photo.id }
            
            // Note: In production, you'd want better tracking between selectedItems and memoryPhotos
            selectedItems.removeAll()
        }
    }
}

// MARK: - Photo Thumbnail View

struct PhotoThumbnailView: View {
    let photo: MemoryPhoto
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            if let uiImage = photo.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .offset(x: 30, y: -30)
        }
    }
}

// MARK: - Movie Picker View (Unchanged)

struct MoviePickerView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMovie: MovieData?
    
    private var movieService: MovieServiceProtocol {
        navigationManager.movieService
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(movieService.getAllMovies()) { movie in
                    Button {
                        selectedMovie = movie
                        dismiss()
                    } label: {
                        HStack {
                            Text(movie.emoji)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(movie.title)
                                    .font(.headline)
                                Text(movie.genre)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedMovie?.id == movie.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Select Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
