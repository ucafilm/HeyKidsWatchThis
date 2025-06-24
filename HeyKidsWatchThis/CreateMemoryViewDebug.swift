// CreateMemoryViewDebug.swift
// Debug version of CreateMemoryView to help identify photo issues

import SwiftUI
import PhotosUI

struct CreateMemoryViewDebug: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    // Existing state
    @State private var selectedMovie: MovieData?
    @State private var rating: Int = 5
    @State private var notes: String = ""
    @State private var watchDate: Date = Date()
    @State private var showingMoviePicker = false
    
    // NEW: Photo state with debug info
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var memoryPhotos: [MemoryPhoto] = []
    @State private var isLoadingPhotos = false
    @State private var photoDebugInfo: [String] = []
    
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
                
                // DEBUG: Photos Section with detailed info
                Section("Photos (Debug)") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Photo Status")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            PhotosPicker(
                                selection: $selectedPhotoItems,
                                maxSelectionCount: 3,
                                matching: .images
                            ) {
                                HStack {
                                    Image(systemName: "photo.badge.plus")
                                    Text("Select")
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                        }
                        
                        // Debug Info Display
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selected Items: \(selectedPhotoItems.count)")
                                .font(.caption)
                            Text("Loaded Photos: \(memoryPhotos.count)")
                                .font(.caption)
                            Text("Loading: \(isLoadingPhotos ? "YES" : "NO")")
                                .font(.caption)
                                .foregroundColor(isLoadingPhotos ? .orange : .green)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        
                        // Photo thumbnails with debug info
                        if !memoryPhotos.isEmpty {
                            Text("Photos:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(memoryPhotos.enumerated()), id: \.element.id) { index, photo in
                                        VStack(spacing: 4) {
                                            if let uiImage = photo.uiImage {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 60, height: 60)
                                                    .clipped()
                                                    .cornerRadius(6)
                                            } else {
                                                Rectangle()
                                                    .fill(Color.red.opacity(0.3))
                                                    .frame(width: 60, height: 60)
                                                    .cornerRadius(6)
                                                    .overlay(
                                                        Text("❌")
                                                            .font(.title2)
                                                    )
                                            }
                                            
                                            Text("#\(index + 1)")
                                                .font(.caption2)
                                            Text("\(photo.estimatedFileSize)b")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                        
                        // Debug messages
                        if !photoDebugInfo.isEmpty {
                            Text("Debug Log:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(Array(photoDebugInfo.enumerated()), id: \.offset) { index, message in
                                        Text("\(index + 1). \(message)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .frame(maxHeight: 100)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                        }
                    }
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
            .navigationTitle("Create Memory (Debug)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMemory()
                    }
                    .disabled(selectedMovie == nil || isLoadingPhotos)
                }
            }
            .sheet(isPresented: $showingMoviePicker) {
                MoviePickerView(selectedMovie: $selectedMovie)
                    .environmentObject(navigationManager)
            }
            .onChange(of: selectedPhotoItems) { oldItems, newItems in
                debugLoadPhotos(newItems)
            }
        }
    }
    
    private func debugLoadPhotos(_ items: [PhotosPickerItem]) {
        photoDebugInfo.append("📱 PhotosPicker onChange: \(items.count) items")
        isLoadingPhotos = true
        memoryPhotos.removeAll()
        
        Task {
            photoDebugInfo.append("🔄 Starting Task for \(items.count) items")
            
            for (index, item) in items.enumerated() {
                do {
                    photoDebugInfo.append("⬇️ Loading item \(index + 1)...")
                    
                    if let imageData = try await item.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            photoDebugInfo.append("✅ Item \(index + 1): \(imageData.count) bytes")
                        }
                        
                        let photo = MemoryPhoto(imageData: imageData, caption: "Photo \(index + 1)")
                        
                        await MainActor.run {
                            memoryPhotos.append(photo)
                            photoDebugInfo.append("➕ Added to array. Count: \(memoryPhotos.count)")
                        }
                    } else {
                        await MainActor.run {
                            photoDebugInfo.append("❌ Item \(index + 1): No data")
                        }
                    }
                } catch {
                    await MainActor.run {
                        photoDebugInfo.append("💥 Item \(index + 1): \(error.localizedDescription)")
                    }
                }
            }
            
            await MainActor.run {
                isLoadingPhotos = false
                photoDebugInfo.append("🏁 Complete. Final: \(memoryPhotos.count) photos")
            }
        }
    }
    
    private func saveMemory() {
        guard let movie = selectedMovie else { return }
        
        let memory = MemoryData(
            movieId: movie.id,
            watchDate: watchDate,
            rating: rating,
            notes: notes.isEmpty ? nil : notes,
            photos: memoryPhotos  // Include photos in the memory
        )
        
        photoDebugInfo.append("💾 Saving memory with \(memoryPhotos.count) photos")
        
        let memoryService = navigationManager.memoryService
        let success = memoryService.createMemory(memory)
        
        if success {
            photoDebugInfo.append("✅ Memory saved successfully!")
            HapticFeedbackManager.shared.triggerSuccess()
            dismiss()
        } else {
            photoDebugInfo.append("❌ Memory save failed!")
            HapticFeedbackManager.shared.triggerError()
        }
    }
}
