// PhotoDebugView.swift
// Debug helper for photo integration issues

import SwiftUI
import PhotosUI

struct PhotoDebugView: View {
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var memoryPhotos: [MemoryPhoto] = []
    @State private var isLoadingPhotos = false
    @State private var debugMessages: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Photo Debug Tool")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Photo Selection
                PhotosPicker(
                    selection: $selectedPhotoItems,
                    maxSelectionCount: 5,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("Select Photos")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                if isLoadingPhotos {
                    ProgressView("Loading photos...")
                }
                
                // Debug Messages
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug Log:")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(debugMessages.enumerated()), id: \.offset) { index, message in
                                Text("\(index + 1). \(message)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Photo Display
                if !memoryPhotos.isEmpty {
                    Text("Loaded Photos (\(memoryPhotos.count)):")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(memoryPhotos) { photo in
                                VStack {
                                    if let uiImage = photo.uiImage {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                    } else {
                                        Rectangle()
                                            .fill(Color.red.opacity(0.3))
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                            .overlay(
                                                Text("Failed")
                                                    .foregroundColor(.red)
                                            )
                                    }
                                    
                                    Text("\(photo.estimatedFileSize) bytes")
                                        .font(.caption2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button("Clear All") {
                    selectedPhotoItems.removeAll()
                    memoryPhotos.removeAll()
                    debugMessages.removeAll()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .padding()
            .onChange(of: selectedPhotoItems) { oldItems, newItems in
                loadSelectedPhotos(newItems)
            }
        }
    }
    
    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) {
        debugMessages.append("PhotosPicker changed: \(items.count) items selected")
        
        isLoadingPhotos = true
        memoryPhotos.removeAll()
        
        Task {
            debugMessages.append("Starting async photo loading...")
            
            for (index, item) in items.enumerated() {
                do {
                    debugMessages.append("Loading photo \(index + 1)...")
                    
                    if let imageData = try await item.loadTransferable(type: Data.self) {
                        debugMessages.append("✅ Photo \(index + 1) loaded: \(imageData.count) bytes")
                        
                        let photo = MemoryPhoto(imageData: imageData, caption: "Debug Photo \(index + 1)")
                        
                        await MainActor.run {
                            memoryPhotos.append(photo)
                            debugMessages.append("✅ Photo \(index + 1) added to array. Total: \(memoryPhotos.count)")
                        }
                    } else {
                        await MainActor.run {
                            debugMessages.append("❌ Photo \(index + 1) failed: No data")
                        }
                    }
                } catch {
                    await MainActor.run {
                        debugMessages.append("❌ Photo \(index + 1) error: \(error.localizedDescription)")
                    }
                }
            }
            
            await MainActor.run {
                isLoadingPhotos = false
                debugMessages.append("🏁 Photo loading complete. Final count: \(memoryPhotos.count)")
            }
        }
    }
}

#Preview {
    PhotoDebugView()
}
