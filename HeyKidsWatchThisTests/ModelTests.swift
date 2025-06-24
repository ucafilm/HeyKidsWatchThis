import XCTest
@testable import HeyKidsWatchThis

class ModelTests: XCTestCase {
    
    func testAgeGroupProperties() {
        // Test that all age groups have correct properties
        XCTAssertEqual(AgeGroup.preschoolers.emoji, "🧸")
        XCTAssertEqual(AgeGroup.preschoolers.ageRange, "2-4")
        XCTAssertEqual(AgeGroup.preschoolers.description, "Preschoolers")
        
        XCTAssertEqual(AgeGroup.littleKids.emoji, "🎨")
        XCTAssertEqual(AgeGroup.bigKids.emoji, "🚀")
        XCTAssertEqual(AgeGroup.tweens.emoji, "🎭")
    }
    
    func testMovieDataInitialization() {
        let movie = MovieData(
            title: "Test Movie",
            year: 2024,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🎬",
            streamingServices: ["Netflix"]
        )
        
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.year, 2024)
        XCTAssertEqual(movie.ageGroup, .littleKids)
        XCTAssertEqual(movie.genre, "Animation")
        XCTAssertEqual(movie.streamingServices, ["Netflix"])
        XCTAssertNil(movie.rating)
        XCTAssertNil(movie.notes)
    }
    
    func testMovieDataCodable() {
        let movie = MovieData(
            title: "Codable Test",
            year: 2024,
            ageGroup: .bigKids,
            genre: "Adventure",
            emoji: "🚀",
            streamingServices: ["Disney+"],
            rating: 4.8,
            notes: "Great movie"
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try! encoder.encode(movie)
        XCTAssertFalse(encoded.isEmpty, "Encoded data should not be empty")
        
        // Test decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try! decoder.decode(MovieData.self, from: encoded)
        
        XCTAssertEqual(movie.id, decoded.id)
        XCTAssertEqual(movie.title, decoded.title)
        XCTAssertEqual(movie.ageGroup, decoded.ageGroup)
    }
}
