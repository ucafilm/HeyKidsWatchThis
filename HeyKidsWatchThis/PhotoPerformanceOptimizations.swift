//
//  PhotoPerformanceOptimizations.swift
//  HeyKidsWatchThis
//
//  TDD REFACTOR PHASE: Performance optimizations and polish
//  Improving photo loading, caching, and user experience
//

import SwiftUI
import UIKit

/// Performance optimizations for photo operations
struct PhotoPerformanceOptimizations {
    
    // MARK: - Image Caching
    
    /// Simple in-memory cache for loaded UIImages
    private static var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 50 // Limit to 50 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
        return cache
    }()
    
    /// Cached image loading with fallback
    static func cachedImage(for photo: MemoryPhoto) -> UIImage? {
        let cacheKey = photo.id.uuidString as NSString
        
        // Check cache first
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Load from data and cache
        if let image = UIImage(data: photo.imageData) {
            imageCache.setObject(image, forKey: cacheKey)
            return image
        }
        
        return nil
    }
    
    /// Clear cache when memory warning occurs
    static func clearImageCache() {
        imageCache.removeAllObjects()
    }
    
    // MARK: - Thumbnail Generation
    
    /// Generate optimized thumbnails for grid display
    static func generateOptimizedThumbnail(
        from imageData: Data, 
        targetSize: CGSize = CGSize(width: 100, height: 100)
    ) -> UIImage? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let thumbnail = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return thumbnail
    }
    
    // MARK: - Performance Monitoring
    
    /// Monitor photo loading performance
    static func measurePhotoLoadingTime<T>(operation: () -> T) -> (result: T, duration: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        
        // Log performance if it's slow
        if duration > 0.1 { // More than 100ms
            print("⚠️ Slow photo operation detected: \(duration * 1000)ms")
        }
        
        return (result, duration)
    }
}

/// Enhanced MemoryPhoto with performance optimizations
extension MemoryPhoto {
    
    /// Cached UIImage with performance optimizations
    var optimizedUIImage: UIImage? {
        return PhotoPerformanceOptimizations.cachedImage(for: self)
    }
    
    /// Generate thumbnail for grid display
    var thumbnailImage: UIImage? {
        return PhotoPerformanceOptimizations.generateOptimizedThumbnail(from: imageData)
    }
    
    /// Estimated memory usage
    var memoryFootprint: Int {
        return imageData.count
    }
    
    /// Is this a large photo that might need compression?
    var isLargePhoto: Bool {
        return imageData.count > 2 * 1024 * 1024 // 2MB
    }
}

/// Memory management for photo collections
struct PhotoCollectionOptimizer {
    
    /// Optimize a collection of photos for display
    static func optimizeForDisplay(_ photos: [MemoryPhoto]) -> [MemoryPhoto] {
        return photos.map { photo in
            if photo.isLargePhoto {
                // Compress large photos for better performance
                let compressedData = PhotoMemoryService().compressImageData(
                    photo.imageData, 
                    quality: 0.7
                )
                
                return MemoryPhoto(
                    id: photo.id,
                    imageData: compressedData,
                    caption: photo.caption,
                    captureDate: photo.captureDate,
                    compressionQuality: 0.7
                )
            }
            return photo
        }
    }
    
    /// Calculate total memory usage of photo collection
    static func calculateMemoryUsage(_ photos: [MemoryPhoto]) -> Int {
        return photos.reduce(0) { $0 + $1.memoryFootprint }
    }
    
    /// Check if collection needs optimization
    static func needsOptimization(_ photos: [MemoryPhoto]) -> Bool {
        let totalSize = calculateMemoryUsage(photos)
        return totalSize > 10 * 1024 * 1024 // 10MB threshold
    }
}

/// Enhanced PhotoGridView with performance optimizations
struct OptimizedPhotoGridView: View {
    let photos: [MemoryPhoto]
    let onPhotoTap: (MemoryPhoto) -> Void
    let onPhotoDelete: ((MemoryPhoto) -> Void)?
    
    // Optimized grid configuration
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(photos) { photo in
                OptimizedPhotoThumbnail(
                    photo: photo,
                    onTap: { onPhotoTap(photo) },
                    onDelete: onPhotoDelete != nil ? { onPhotoDelete!(photo) } : nil
                )
            }
        }
    }
}

/// Optimized photo thumbnail with caching
struct OptimizedPhotoThumbnail: View {
    let photo: MemoryPhoto
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    @State private var thumbnailImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Photo display with loading state
            Group {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(12)
                } else if isLoading {
                    // Loading placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                } else {
                    // Error state
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Delete button overlay
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
        .task {
            await loadThumbnail()
        }
        .onAppear {
            if thumbnailImage == nil {
                Task {
                    await loadThumbnail()
                }
            }
        }
    }
    
    @MainActor
    private func loadThumbnail() async {
        // Use cached version if available
        if let cached = photo.optimizedUIImage {
            thumbnailImage = cached
            isLoading = false
            return
        }
        
        // Generate thumbnail in background
        let thumbnail = await Task.detached {
            return photo.thumbnailImage
        }.value
        
        thumbnailImage = thumbnail
        isLoading = false
    }
}
