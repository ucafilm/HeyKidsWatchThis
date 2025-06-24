// PhotoMemoryService.swift
// HeyKidsWatchThis - Photo Memory Service Implementation
// GREEN PHASE: Minimal implementation to pass tests

import Foundation
import UIKit

protocol PhotoMemoryServiceProtocol {
    func savePhoto(_ photo: MemoryPhoto, for memoryId: UUID) -> Result<Void, StorageError>
    func loadPhotos(for memoryId: UUID) -> [MemoryPhoto]
    func deletePhoto(_ photoId: UUID, for memoryId: UUID) -> Result<Void, StorageError>
    func compressImageData(_ imageData: Data, quality: Double) -> Data
    func generateThumbnail(from imageData: Data, size: CGSize) -> Data?
}

class PhotoMemoryService: PhotoMemoryServiceProtocol {
    private let storage: FileManagerStorageProtocol
    private let maxPhotoSize: Int = 5 * 1024 * 1024 // 5MB limit
    
    init(storage: FileManagerStorageProtocol = FileManagerStorage()) {
        self.storage = storage
    }
    
    func savePhoto(_ photo: MemoryPhoto, for memoryId: UUID) -> Result<Void, StorageError> {
        // Create photo filename
        let fileName = "photo_\(photo.id.uuidString).jpg"
        
        // Compress if needed
        let finalImageData: Data
        if photo.imageData.count > maxPhotoSize {
            finalImageData = compressImageData(photo.imageData, quality: 0.6)
        } else {
            finalImageData = photo.imageData
        }
        
        // Create updated photo with compressed data
        let compressedPhoto = MemoryPhoto(
            id: photo.id,
            imageData: finalImageData,
            caption: photo.caption,
            captureDate: photo.captureDate,
            compressionQuality: photo.compressionQuality
        )
        
        return storage.save(compressedPhoto, to: fileName, in: .documents)
    }
    
    func loadPhotos(for memoryId: UUID) -> [MemoryPhoto] {
        // List all files and filter for photos
        let filesResult = storage.listFiles(in: .documents)
        
        switch filesResult {
        case .success(let files):
            let photoFiles = files.filter { $0.hasPrefix("photo_") && $0.hasSuffix(".jpg") }
            
            var photos: [MemoryPhoto] = []
            for fileName in photoFiles {
                let loadResult = storage.load(MemoryPhoto.self, from: fileName, in: .documents)
                if case .success(let photo) = loadResult {
                    photos.append(photo)
                }
            }
            
            // Sort by capture date
            return photos.sorted { $0.captureDate < $1.captureDate }
            
        case .failure:
            return []
        }
    }
    
    func deletePhoto(_ photoId: UUID, for memoryId: UUID) -> Result<Void, StorageError> {
        let fileName = "photo_\(photoId.uuidString).jpg"
        return storage.delete(fileName: fileName, in: .documents)
    }
    
    func compressImageData(_ imageData: Data, quality: Double) -> Data {
        guard let image = UIImage(data: imageData),
              let compressedData = image.jpegData(compressionQuality: quality) else {
            return imageData
        }
        return compressedData
    }
    
    func generateThumbnail(from imageData: Data, size: CGSize) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let thumbnail = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return thumbnail.jpegData(compressionQuality: 0.8)
    }
}
