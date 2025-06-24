//
//  PhotoGridView.swift
//  HeyKidsWatchThis
//
//  TDD GREEN PHASE: PhotoGridView component implementation
//  This will make PhotoGridViewLayoutTests pass
//

import SwiftUI

/// Grid view for displaying memory photos in an adaptive layout
struct PhotoGridView: View {
    let photos: [MemoryPhoto]
    let onPhotoTap: (MemoryPhoto) -> Void
    let onPhotoDelete: ((MemoryPhoto) -> Void)?
    
    // Grid configuration - adaptive columns with minimum 100pt width, 12pt spacing
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(photos) { photo in
                PhotoThumbnailGridItem(
                    photo: photo,
                    onTap: { onPhotoTap(photo) },
                    onDelete: onPhotoDelete != nil ? { onPhotoDelete!(photo) } : nil
                )
            }
        }
    }
}

/// Individual photo thumbnail component for grid display
struct PhotoThumbnailGridItem: View {
    let photo: MemoryPhoto
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Photo display with correct aspect ratio and sizing
            if let uiImage = photo.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(12)
            } else {
                // Fallback for photos that fail to load
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
            
            // Delete button overlay (only shown when deletion enabled)
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .font(.title3)
                }
                .offset(x: 40, y: -40)
            }
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview Support

#Preview("PhotoGridView with Photos") {
    let samplePhotos = [
        MemoryPhoto(imageData: Data([1, 2, 3]), caption: "Family watching"),
        MemoryPhoto(imageData: Data([4, 5, 6]), caption: "Popcorn time"),
        MemoryPhoto(imageData: Data([7, 8, 9]), caption: "Movie night setup"),
        MemoryPhoto(imageData: Data([10, 11, 12]), caption: "Everyone together")
    ]
    
    return ScrollView {
        PhotoGridView(
            photos: samplePhotos,
            onPhotoTap: { photo in
                print("Tapped photo: \(photo.caption ?? "No caption")")
            },
            onPhotoDelete: { photo in
                print("Delete photo: \(photo.caption ?? "No caption")")
            }
        )
        .padding()
    }
}

#Preview("PhotoGridView Empty State") {
    PhotoGridView(
        photos: [],
        onPhotoTap: { _ in },
        onPhotoDelete: nil
    )
    .padding()
}

#Preview("PhotoThumbnailGridItem") {
    let samplePhoto = MemoryPhoto(imageData: Data([1, 2, 3]), caption: "Sample photo")
    
    return VStack(spacing: 20) {
        // With delete button
        PhotoThumbnailGridItem(
            photo: samplePhoto,
            onTap: { print("Photo tapped") },
            onDelete: { print("Photo deleted") }
        )
        
        // Without delete button
        PhotoThumbnailGridItem(
            photo: samplePhoto,
            onTap: { print("Photo tapped") },
            onDelete: nil
        )
    }
    .padding()
}
