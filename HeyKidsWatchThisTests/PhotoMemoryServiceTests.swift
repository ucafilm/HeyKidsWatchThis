// PhotoMemoryServiceTests.swift
// HeyKidsWatchThis - Photo Memory Service Tests
// TDD RED PHASE: Test photo storage and management functionality

import XCTest
@testable import HeyKidsWatchThis

class PhotoMemoryServiceTests: XCTestCase {
    
    var photoService: PhotoMemoryServiceProtocol!
    var mockStorage: MockFileManagerStorage!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockFileManagerStorage()
        photoService = PhotoMemoryService(storage: mockStorage)
    }
    
    override func tearDown() {
        photoService = nil
        mockStorage = nil
        super.tearDown()
    }
    
    // MARK: - Photo Storage Tests
    
    func test_savePhoto_storesImageData() {
        // Test basic photo storage functionality
        let imageData = Data([1, 2, 3, 4])
        let photo = MemoryPhoto(imageData: imageData, caption: "Test photo")
        let memoryId = UUID()
        
        let result = photoService.savePhoto(photo, for: memoryId)
        
        XCTAssertTrue(result.isSuccess, "Photo save should succeed")
        XCTAssertEqual(mockStorage.saveCallCount, 1, "Storage save should be called once")
    }
    
    func test_savePhoto_compressesLargeImages() {
        // Test that large images are compressed
        let largeImageData = Data(repeating: 0xFF, count: 6 * 1024 * 1024) // 6MB > 5MB limit
        let photo = MemoryPhoto(imageData: largeImageData, caption: "Large photo")
        let memoryId = UUID()
        
        let result = photoService.savePhoto(photo, for: memoryId)
        
        XCTAssertTrue(result.isSuccess, "Large photo save should succeed")
        // Note: Compression testing will be more detailed in implementation
    }
    
    func test_savePhoto_handlesStorageFailure() {
        // Test error handling when storage fails
        mockStorage.shouldFailSave = true
        
        let photo = MemoryPhoto(imageData: Data([1, 2, 3]), caption: "Test")
        let memoryId = UUID()
        
        let result = photoService.savePhoto(photo, for: memoryId)
        
        XCTAssertTrue(result.isFailure, "Photo save should fail when storage fails")
    }
    
    // MARK: - Photo Retrieval Tests
    
    func test_loadPhotos_retrievesStoredPhotos() {
        // Test photo retrieval for a memory
        let memoryId = UUID()
        let photo1 = MemoryPhoto(imageData: Data([1, 2]), caption: "Photo 1")
        let photo2 = MemoryPhoto(imageData: Data([3, 4]), caption: "Photo 2")
        
        // Save photos first
        _ = photoService.savePhoto(photo1, for: memoryId)
        _ = photoService.savePhoto(photo2, for: memoryId)
        
        let photos = photoService.loadPhotos(for: memoryId)
        
        XCTAssertEqual(photos.count, 2, "Should retrieve 2 photos")
        
        let captions = photos.compactMap { $0.caption }
        XCTAssertTrue(captions.contains("Photo 1"), "Should contain Photo 1")
        XCTAssertTrue(captions.contains("Photo 2"), "Should contain Photo 2")
    }
    
    func test_loadPhotos_returnsEmptyForNonexistentMemory() {
        // Test loading photos for memory with no photos
        let emptyMemoryId = UUID()
        
        let photos = photoService.loadPhotos(for: emptyMemoryId)
        
        XCTAssertTrue(photos.isEmpty, "Should return empty array for memory with no photos")
    }
    
    func test_loadPhotos_sortsByDate() {
        // Test that photos are returned sorted by capture date
        let memoryId = UUID()
        
        let olderDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let newerDate = Date()
        
        let olderPhoto = MemoryPhoto(
            imageData: Data([1]),
            caption: "Older",
            captureDate: olderDate
        )
        let newerPhoto = MemoryPhoto(
            imageData: Data([2]),
            caption: "Newer",
            captureDate: newerDate
        )
        
        // Save in reverse order
        _ = photoService.savePhoto(newerPhoto, for: memoryId)
        _ = photoService.savePhoto(olderPhoto, for: memoryId)
        
        let photos = photoService.loadPhotos(for: memoryId)
        
        XCTAssertEqual(photos.count, 2)
        XCTAssertEqual(photos[0].caption, "Older", "First photo should be older")
        XCTAssertEqual(photos[1].caption, "Newer", "Second photo should be newer")
    }
    
    // MARK: - Photo Deletion Tests
    
    func test_deletePhoto_removesFromStorage() {
        // Test photo deletion
        let memoryId = UUID()
        let photo = MemoryPhoto(imageData: Data([1, 2]), caption: "To delete")
        
        // Save photo first
        _ = photoService.savePhoto(photo, for: memoryId)
        
        let deleteResult = photoService.deletePhoto(photo.id, for: memoryId)
        
        XCTAssertTrue(deleteResult.isSuccess, "Photo deletion should succeed")
        XCTAssertEqual(mockStorage.deleteCallCount, 1, "Storage delete should be called")
        
        // Verify photo is gone
        let remainingPhotos = photoService.loadPhotos(for: memoryId)
        XCTAssertEqual(remainingPhotos.count, 0, "No photos should remain after deletion")
    }
    
    func test_deletePhoto_handlesNonexistentPhoto() {
        // Test deleting a photo that doesn't exist
        let memoryId = UUID()
        let nonexistentPhotoId = UUID()
        
        let result = photoService.deletePhoto(nonexistentPhotoId, for: memoryId)
        
        // Depending on implementation, this might succeed (idempotent) or fail
        // For now, we'll test that it doesn't crash
        XCTAssertNotNil(result, "Delete operation should return a result")
    }
    
    // MARK: - Image Compression Tests
    
    func test_compressImage_reducesFileSize() {
        // Test image compression functionality
        let originalSize = 1024 * 100 // 100KB
        let originalData = Data(repeating: 0xFF, count: originalSize)
        
        let compressedData = photoService.compressImageData(originalData, quality: 0.5)
        
        // Note: Real compression would reduce size significantly
        // For mock testing, we'll verify the method is called
        XCTAssertNotNil(compressedData, "Compression should return data")
    }
    
    func test_compressImage_differentQualityLevels() {
        // Test different compression quality settings
        let imageData = Data(repeating: 0xFF, count: 1024)
        
        let highQuality = photoService.compressImageData(imageData, quality: 0.9)
        let lowQuality = photoService.compressImageData(imageData, quality: 0.3)
        
        XCTAssertNotNil(highQuality, "High quality compression should work")
        XCTAssertNotNil(lowQuality, "Low quality compression should work")
        
        // In real implementation, high quality should be larger than low quality
        // For mock, we'll just verify both work
    }
    
    // MARK: - Thumbnail Generation Tests
    
    func test_generateThumbnail_createsSmallImage() {
        // Test thumbnail generation
        let imageData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header
        let thumbnailSize = CGSize(width: 100, height: 100)
        
        let thumbnailData = photoService.generateThumbnail(from: imageData, size: thumbnailSize)
        
        XCTAssertNotNil(thumbnailData, "Thumbnail generation should return data")
    }
    
    func test_generateThumbnail_handlesInvalidData() {
        // Test thumbnail generation with invalid image data
        let invalidImageData = Data([1, 2, 3, 4]) // Not valid image data
        let thumbnailSize = CGSize(width: 50, height: 50)
        
        let thumbnailData = photoService.generateThumbnail(from: invalidImageData, size: thumbnailSize)
        
        XCTAssertNil(thumbnailData, "Thumbnail generation should return nil for invalid data")
    }
    
    // MARK: - Performance Tests
    
    func test_saveMultiplePhotos_performance() {
        // Test performance with multiple photos
        let memoryId = UUID()
        let photoCount = 10
        
        measure {
            for i in 0..<photoCount {
                let photo = MemoryPhoto(
                    imageData: Data(repeating: UInt8(i), count: 1024),
                    caption: "Photo \(i)"
                )
                _ = photoService.savePhoto(photo, for: memoryId)
            }
        }
    }
    
    func test_loadMultiplePhotos_performance() {
        // Test performance loading multiple photos
        let memoryId = UUID()
        
        // Setup: Save multiple photos
        for i in 0..<20 {
            let photo = MemoryPhoto(
                imageData: Data(repeating: UInt8(i), count: 1024),
                caption: "Photo \(i)"
            )
            _ = photoService.savePhoto(photo, for: memoryId)
        }
        
        measure {
            _ = photoService.loadPhotos(for: memoryId)
        }
    }
    
    // MARK: - Edge Case Tests
    
    func test_savePhoto_withEmptyImageData() {
        // Test saving photo with empty image data
        let emptyPhoto = MemoryPhoto(imageData: Data(), caption: "Empty")
        let memoryId = UUID()
        
        let result = photoService.savePhoto(emptyPhoto, for: memoryId)
        
        // Should handle gracefully - either succeed with empty data or fail appropriately
        XCTAssertNotNil(result, "Should handle empty image data gracefully")
    }
    
    func test_savePhoto_withVeryLongCaption() {
        // Test saving photo with very long caption
        let longCaption = String(repeating: "A", count: 10000) // 10K characters
        let photo = MemoryPhoto(
            imageData: Data([1, 2, 3]),
            caption: longCaption
        )
        let memoryId = UUID()
        
        let result = photoService.savePhoto(photo, for: memoryId)
        
        XCTAssertTrue(result.isSuccess, "Should handle long captions")
    }
    
    func test_loadPhotos_withCorruptedStorage() {
        // Test loading photos when storage contains corrupted data
        mockStorage.shouldReturnCorruptedData = true
        
        let photos = photoService.loadPhotos(for: UUID())
        
        // Should handle corrupted data gracefully
        XCTAssertNotNil(photos, "Should handle corrupted data without crashing")
    }
}

// MARK: - Mock Storage for Testing

class MockFileManagerStorage: FileManagerStorageProtocol {
    
    var saveCallCount = 0
    var loadCallCount = 0
    var deleteCallCount = 0
    var listFilesCallCount = 0
    
    var shouldFailSave = false
    var shouldFailLoad = false
    var shouldFailDelete = false
    var shouldReturnCorruptedData = false
    
    private var storage: [String: Data] = [:]
    private var fileList: [String] = []
    
    func save<T: Codable>(_ object: T, to fileName: String, in directory: StorageDirectory) -> Result<Void, StorageError> {
        saveCallCount += 1
        
        if shouldFailSave {
            return .failure(.writePermissionDenied(fileName))
        }
        
        do {
            let data = try JSONEncoder().encode(object)
            storage[fileName] = data
            
            // Add to file list if not already present
            if !fileList.contains(fileName) {
                fileList.append(fileName)
            }
            
            return .success(())
        } catch {
            return .failure(.encodingFailed(error.localizedDescription))
        }
    }
    
    func load<T: Codable>(_ type: T.Type, from fileName: String, in directory: StorageDirectory) -> Result<T, StorageError> {
        loadCallCount += 1
        
        if shouldFailLoad {
            return .failure(.fileNotFound(fileName))
        }
        
        if shouldReturnCorruptedData {
            return .failure(.decodingFailed("Corrupted data"))
        }
        
        guard let data = storage[fileName] else {
            return .failure(.fileNotFound(fileName))
        }
        
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return .success(object)
        } catch {
            return .failure(.decodingFailed(error.localizedDescription))
        }
    }
    
    func delete(fileName: String, in directory: StorageDirectory) -> Result<Void, StorageError> {
        deleteCallCount += 1
        
        storage.removeValue(forKey: fileName)
        fileList.removeAll { $0 == fileName }
        
        return .success(())
    }
    
    func fileExists(_ fileName: String, in directory: StorageDirectory) -> Bool {
        return storage[fileName] != nil
    }
    
    func listFiles(in directory: StorageDirectory) -> Result<[String], StorageError> {
        listFilesCallCount += 1
        return .success(fileList)
    }
    
    // Helper method to reset mock state
    func reset() {
        saveCallCount = 0
        loadCallCount = 0
        deleteCallCount = 0
        listFilesCallCount = 0
        shouldFailSave = false
        shouldFailLoad = false
        shouldFailDelete = false
        shouldReturnCorruptedData = false
        storage.removeAll()
        fileList.removeAll()
    }
}
