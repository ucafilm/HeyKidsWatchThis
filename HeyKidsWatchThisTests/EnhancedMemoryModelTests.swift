// EnhancedMemoryModelTests.swift
// HeyKidsWatchThis - Enhanced Memory Model Tests
// TDD RED PHASE: Write failing tests first for photo integration

import XCTest
@testable import HeyKidsWatchThis

class EnhancedMemoryModelTests: XCTestCase {
    
    // MARK: - MemoryPhoto Model Tests
    
    func test_memoryPhoto_initializesCorrectly() {
        // Test new MemoryPhoto model initialization
        let photoData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header bytes
        let captureDate = Date()
        let photo = MemoryPhoto(
            id: UUID(),
            imageData: photoData,
            caption: "Family movie night!",
            captureDate: captureDate
        )
        
        XCTAssertNotNil(photo.id)
        XCTAssertEqual(photo.imageData, photoData)
        XCTAssertEqual(photo.caption, "Family movie night!")
        XCTAssertEqual(photo.captureDate, captureDate)
        XCTAssertEqual(photo.compressionQuality, 0.8, "Default compression should be 0.8")
    }
    
    func test_memoryPhoto_defaultInitialization() {
        // Test MemoryPhoto with minimal parameters
        let imageData = Data([1, 2, 3, 4])
        let photo = MemoryPhoto(imageData: imageData)
        
        XCTAssertNotNil(photo.id)
        XCTAssertEqual(photo.imageData, imageData)
        XCTAssertNil(photo.caption)
        XCTAssertLessThan(abs(photo.captureDate.timeIntervalSinceNow), 1.0, "Capture date should be recent")
        XCTAssertEqual(photo.compressionQuality, 0.8)
    }
    
    func test_memoryPhoto_estimatedFileSize() {
        // Test file size calculation
        let imageData = Data(repeating: 0xFF, count: 1024) // 1KB of data
        let photo = MemoryPhoto(imageData: imageData)
        
        XCTAssertEqual(photo.estimatedFileSize, 1024)
    }
    
    func test_memoryPhoto_codableCompliance() {
        // Test JSON encoding/decoding for persistence
        let photo = MemoryPhoto(
            imageData: Data([1, 2, 3, 4]),
            caption: "Test photo",
            compressionQuality: 0.7
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // Test encoding doesn't throw
        XCTAssertNoThrow(try encoder.encode(photo))
        
        // Test round-trip encoding/decoding
        do {
            let encoded = try encoder.encode(photo)
            let decoded = try decoder.decode(MemoryPhoto.self, from: encoded)
            
            XCTAssertEqual(decoded.id, photo.id)
            XCTAssertEqual(decoded.caption, photo.caption)
            XCTAssertEqual(decoded.imageData, photo.imageData)
            XCTAssertEqual(decoded.compressionQuality, photo.compressionQuality)
        } catch {
            XCTFail("Encoding/Decoding failed: \(error)")
        }
    }
    
    func test_memoryPhoto_equalityComparison() {
        // Test Equatable conformance
        let id = UUID()
        let imageData = Data([1, 2, 3])
        
        let photo1 = MemoryPhoto(id: id, imageData: imageData, caption: "Same")
        let photo2 = MemoryPhoto(id: id, imageData: imageData, caption: "Same")
        let photo3 = MemoryPhoto(imageData: imageData, caption: "Different")
        
        XCTAssertEqual(photo1, photo2, "Photos with same data should be equal")
        XCTAssertNotEqual(photo1, photo3, "Photos with different IDs should not be equal")
    }
    
    // MARK: - Enhanced MemoryData Tests
    
    func test_memoryData_supportsPhotos() {
        // Test that MemoryData can store multiple photos
        let photo1 = MemoryPhoto(imageData: Data([1, 2, 3]), caption: "Before movie")
        let photo2 = MemoryPhoto(imageData: Data([4, 5, 6]), caption: "During movie")
        let photos = [photo1, photo2]
        
        let memory = MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 5,
            notes: "Great night!",
            photos: photos
        )
        
        XCTAssertEqual(memory.photos.count, 2)
        XCTAssertEqual(memory.photos[0].caption, "Before movie")
        XCTAssertEqual(memory.photos[1].caption, "During movie")
    }
    
    func test_memoryData_emptyPhotosDefault() {
        // Test that MemoryData defaults to empty photos array
        let memory = MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 4,
            notes: "Good movie"
        )
        
        XCTAssertTrue(memory.photos.isEmpty, "Photos should default to empty array")
    }
    
    func test_memoryData_withLocationContext() {
        // Test location context integration
        let coordinate = LocationContext.Coordinate(latitude: 40.7128, longitude: -74.0060)
        let location = LocationContext(name: "Home Theater", coordinate: coordinate)
        
        let memory = MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 5,
            location: location
        )
        
        XCTAssertEqual(memory.location?.name, "Home Theater")
        XCTAssertEqual(memory.location?.coordinate?.latitude, 40.7128)
        XCTAssertEqual(memory.location?.coordinate?.longitude, -74.0060)
    }
    
    func test_memoryData_withWeatherContext() {
        // Test weather context integration
        let weather = WeatherContext(
            temperature: "72°F",
            condition: "Clear",
            icon: "sun.max"
        )
        
        let memory = MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 4,
            weatherContext: weather
        )
        
        XCTAssertEqual(memory.weatherContext?.temperature, "72°F")
        XCTAssertEqual(memory.weatherContext?.condition, "Clear")
        XCTAssertEqual(memory.weatherContext?.icon, "sun.max")
    }
    
    func test_memoryData_codableWithEnhancements() {
        // Test that enhanced MemoryData remains Codable
        let photo = MemoryPhoto(imageData: Data([1, 2, 3]), caption: "Test")
        let location = LocationContext(name: "Cinema", coordinate: nil)
        let weather = WeatherContext(temperature: "70°F", condition: "Cloudy", icon: "cloud")
        
        let memory = MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 4,
            notes: "Great movie!",
            photos: [photo],
            location: location,
            weatherContext: weather
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        XCTAssertNoThrow(try encoder.encode(memory))
        
        do {
            let encoded = try encoder.encode(memory)
            let decoded = try decoder.decode(MemoryData.self, from: encoded)
            
            XCTAssertEqual(decoded.id, memory.id)
            XCTAssertEqual(decoded.photos.count, 1)
            XCTAssertEqual(decoded.location?.name, "Cinema")
            XCTAssertEqual(decoded.weatherContext?.temperature, "70°F")
        } catch {
            XCTFail("Enhanced MemoryData encoding/decoding failed: \(error)")
        }
    }
    
    // MARK: - LocationContext Tests
    
    func test_locationContext_withoutCoordinate() {
        // Test location context with just a name
        let location = LocationContext(name: "Home", coordinate: nil)
        
        XCTAssertEqual(location.name, "Home")
        XCTAssertNil(location.coordinate)
    }
    
    func test_locationContext_withCoordinate() {
        // Test location context with coordinates
        let coordinate = LocationContext.Coordinate(latitude: 37.7749, longitude: -122.4194)
        let location = LocationContext(name: "San Francisco", coordinate: coordinate)
        
        XCTAssertEqual(location.name, "San Francisco")
        XCTAssertNotNil(location.coordinate)
        XCTAssertEqual(location.coordinate?.latitude, 37.7749)
        XCTAssertEqual(location.coordinate?.longitude, -122.4194)
    }
    
    // MARK: - WeatherContext Tests
    
    func test_weatherContext_initialization() {
        // Test weather context creation
        let weather = WeatherContext(
            temperature: "68°F",
            condition: "Partly Cloudy",
            icon: "cloud.sun"
        )
        
        XCTAssertEqual(weather.temperature, "68°F")
        XCTAssertEqual(weather.condition, "Partly Cloudy")
        XCTAssertEqual(weather.icon, "cloud.sun")
    }
}

// MARK: - Test Extensions

extension EnhancedMemoryModelTests {
    
    /// Helper method to create sample photo data
    private func createSamplePhotoData(size: Int = 100) -> Data {
        return Data(repeating: 0xFF, count: size)
    }
    
    /// Helper method to create sample memory with photos
    private func createSampleMemoryWithPhotos(photoCount: Int = 2) -> MemoryData {
        let photos = (1...photoCount).map { index in
            MemoryPhoto(
                imageData: createSamplePhotoData(),
                caption: "Photo \(index)"
            )
        }
        
        return MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 5,
            notes: "Sample memory",
            photos: photos
        )
    }
}
