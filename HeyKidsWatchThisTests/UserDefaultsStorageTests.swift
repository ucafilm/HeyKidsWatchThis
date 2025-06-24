import XCTest
@testable import HeyKidsWatchThis

class UserDefaultsStorageTests: XCTestCase {
    
    var userDefaultsStorage: UserDefaultsStorageProtocol!
    var testUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        testUserDefaults = UserDefaults.testSuite(for: String(describing: type(of: self)))
        userDefaultsStorage = UserDefaultsStorage(userDefaults: testUserDefaults)
    }
    
    override func tearDown() {
        UserDefaults.clearTestSuite(testUserDefaults)
        userDefaultsStorage = nil
        testUserDefaults = nil
        super.tearDown()
    }
    
    func testSaveAndLoadString() {
        let testKey = "test_string_key"
        let testValue = "Hello, World!"
        
        let saveSuccess = userDefaultsStorage.save(testValue, forKey: testKey)
        XCTAssertTrue(saveSuccess, "Save operation should succeed")
        
        let loadedValue: String? = userDefaultsStorage.load(String.self, forKey: testKey)
        XCTAssertNotNil(loadedValue, "Loaded value should not be nil")
        XCTAssertEqual(loadedValue, testValue, "Loaded value should match saved value")
    }
    
    func testSaveAndLoadUUIDArray() {
        let testKey = "test_uuid_array_key"
        let testUUIDs = [UUID(), UUID(), UUID()]
        
        let saveSuccess = userDefaultsStorage.save(testUUIDs, forKey: testKey)
        XCTAssertTrue(saveSuccess, "Save operation should succeed")
        
        let loadedUUIDs: [UUID]? = userDefaultsStorage.load([UUID].self, forKey: testKey)
        XCTAssertNotNil(loadedUUIDs, "Loaded UUIDs should not be nil")
        XCTAssertEqual(loadedUUIDs?.count, testUUIDs.count, "Loaded array should have same count")
        XCTAssertEqual(loadedUUIDs, testUUIDs, "Loaded UUIDs should match saved UUIDs")
    }
    
    func testSaveAndLoadMovieData() {
        let testKey = "test_movie_data_key"
        let testMovie = MovieData(
            title: "Test Movie",
            year: 2024,
            ageGroup: .littleKids,
            genre: "Animation",
            emoji: "🎬",
            streamingServices: ["Netflix", "Disney+"],
            rating: 4.5,
            notes: "Great test movie"
        )
        
        let saveSuccess = userDefaultsStorage.save(testMovie, forKey: testKey)
        XCTAssertTrue(saveSuccess, "Save operation should succeed")
        
        let loadedMovie: MovieData? = userDefaultsStorage.load(MovieData.self, forKey: testKey)
        XCTAssertNotNil(loadedMovie, "Loaded movie should not be nil")
        XCTAssertEqual(loadedMovie, testMovie, "Loaded movie should match saved movie")
    }
    
    func testKeyExistence() {
        let testKey = "test_existence_key"
        let testValue = "Test Value"
        
        XCTAssertFalse(userDefaultsStorage.exists(forKey: testKey), "Key should not exist initially")
        
        let saveSuccess = userDefaultsStorage.save(testValue, forKey: testKey)
        XCTAssertTrue(saveSuccess, "Save operation should succeed")
        XCTAssertTrue(userDefaultsStorage.exists(forKey: testKey), "Key should exist after saving")
    }
    
    func testRemoveValue() {
        let testKey = "test_remove_key"
        let testValue = "Value to remove"
        
        let saveSuccess = userDefaultsStorage.save(testValue, forKey: testKey)
        XCTAssertTrue(saveSuccess, "Save operation should succeed")
        XCTAssertTrue(userDefaultsStorage.exists(forKey: testKey), "Key should exist after saving")
        
        userDefaultsStorage.remove(forKey: testKey)
        XCTAssertFalse(userDefaultsStorage.exists(forKey: testKey), "Key should not exist after removal")
        
        let loadedValue: String? = userDefaultsStorage.load(String.self, forKey: testKey)
        XCTAssertNil(loadedValue, "Loaded value should be nil after removal")
    }
}
