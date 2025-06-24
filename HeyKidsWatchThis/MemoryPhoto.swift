// MemoryPhoto.swift
// HeyKidsWatchThis - Memory Photo Model
// GREEN PHASE: Minimal implementation to pass tests

import Foundation
import UIKit

struct MemoryPhoto: Identifiable, Codable, Equatable {
    let id: UUID
    let imageData: Data
    let caption: String?
    let captureDate: Date
    let compressionQuality: Double
    
    init(
        id: UUID = UUID(),
        imageData: Data,
        caption: String? = nil,
        captureDate: Date = Date(),
        compressionQuality: Double = 0.8
    ) {
        self.id = id
        self.imageData = imageData
        self.caption = caption
        self.captureDate = captureDate
        self.compressionQuality = compressionQuality
    }
    
    // Computed property for file size estimation
    var estimatedFileSize: Int {
        return imageData.count
    }
    
    // Thumbnail generation helper
    var thumbnailData: Data? {
        // For now, return the original data - will enhance in REFACTOR phase
        return imageData
    }
}

// MARK: - UIImage Conversion Extensions

extension MemoryPhoto {
    /// Convert photo data to UIImage for display
    var uiImage: UIImage? {
        return UIImage(data: imageData)
    }
    
    /// Create MemoryPhoto from UIImage
    init?(uiImage: UIImage, caption: String? = nil, compressionQuality: Double = 0.8) {
        guard let imageData = uiImage.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        self.init(
            imageData: imageData,
            caption: caption,
            compressionQuality: compressionQuality
        )
    }
}

// MARK: - Supporting Context Models

struct LocationContext: Codable, Equatable {
    let name: String  // "Home", "Regal Cinema", etc.
    let coordinate: Coordinate?
    
    struct Coordinate: Codable, Equatable {
        let latitude: Double
        let longitude: Double
    }
    
    init(name: String, coordinate: Coordinate? = nil) {
        self.name = name
        self.coordinate = coordinate
    }
}

struct WeatherContext: Codable, Equatable {
    let temperature: String
    let condition: String
    let icon: String
    
    init(temperature: String, condition: String, icon: String) {
        self.temperature = temperature
        self.condition = condition
        self.icon = icon
    }
}
