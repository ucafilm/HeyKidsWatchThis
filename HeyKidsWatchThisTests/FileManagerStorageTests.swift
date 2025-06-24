import XCTest
import Foundation
@testable import HeyKidsWatchThis

class FileManagerStorageTests: XCTestCase {
    
    var fileManagerStorage: FileManagerStorageProtocol!
    
    override func setUp() {
        super.setUp()
        fileManagerStorage = FileManagerStorage()
    }
    
    override func tearDown() {
        cleanupTestFiles()
        fileManagerStorage = nil
        super.tearDown()
    }
    
    func testSaveAndLoadSimpleObject() {
        let testObject = TestFileData(name: "Simple Test", value: 42)
        let fileName = "simple_test.json"
        
        let saveResult = fileManagerStorage.save(testObject, to: fileName, in: .caches)
        XCTAssertTrue(saveResult.isSuccess, "Save should succeed")
        
        let loadResult = fileManagerStorage.load(TestFileData.self, from: fileName, in: .caches)
        XCTAssertTrue(loadResult.isSuccess, "Load should succeed")
        
        if case .success(let loadedObject) = loadResult {
            XCTAssertEqual(loadedObject, testObject, "Loaded object should match saved object")
        }
    }
    
    // Fixed testSaveComplexObject function - Replace this in your FileManagerStorageTests.swift

    func testSaveComplexObject() {
        // ✅ FIX: Use the correct MovieData initializer parameters
        let testMovie = MovieData(
            id: UUID(),
            title: "FileManager Test Movie",
            year: 2024,
            ageGroup: .bigKids,
            genre: "Adventure",
            emoji: "🎬",
            streamingServices: ["Netflix", "Disney+"],
            rating: 4.8,
            notes: "Complex object test"
            // ✅ REMOVED: watchedDate parameter (doesn't exist in your MovieData)
        )
        let fileName = "complex_movie_test.json"
        
        let saveResult = fileManagerStorage.save(testMovie, to: fileName, in: .documents)
        XCTAssertTrue(saveResult.isSuccess, "Complex object save should succeed")
        
        let loadResult = fileManagerStorage.load(MovieData.self, from: fileName, in: .documents)
        XCTAssertTrue(loadResult.isSuccess, "Complex object load should succeed")
        
        if case .success(let loadedMovie) = loadResult {
            XCTAssertEqual(loadedMovie, testMovie, "Complex loaded object should match saved")
        }
    }
    
    func testFileExists() {
        let testObject = TestFileData(name: "Exists Test", value: 123)
        let fileName = "exists_test.json"
        
        XCTAssertFalse(fileManagerStorage.fileExists(fileName, in: .caches), "File should not exist initially")
        
        let saveResult = fileManagerStorage.save(testObject, to: fileName, in: .caches)
        XCTAssertTrue(saveResult.isSuccess, "Save should succeed")
        
        XCTAssertTrue(fileManagerStorage.fileExists(fileName, in: .caches), "File should exist after saving")
    }
    
    func testDeleteFile() {
        let testObject = TestFileData(name: "Delete Test", value: 456)
        let fileName = "delete_test.json"
        
        let saveResult = fileManagerStorage.save(testObject, to: fileName, in: .caches)
        XCTAssertTrue(saveResult.isSuccess, "Save should succeed")
        XCTAssertTrue(fileManagerStorage.fileExists(fileName, in: .caches), "File should exist")
        
        let deleteResult = fileManagerStorage.delete(fileName: fileName, in: .caches)
        XCTAssertTrue(deleteResult.isSuccess, "Delete should succeed")
        XCTAssertFalse(fileManagerStorage.fileExists(fileName, in: .caches), "File should not exist after deletion")
    }
    
    func testGetFileURL() {
        let fileName = "url_test.json"
        
        let fileURL = fileManagerStorage.getFileURL(for: fileName, in: .documents)
        XCTAssertNotNil(fileURL, "Should generate valid file URL")
        XCTAssertEqual(fileURL?.lastPathComponent, fileName, "URL should contain correct filename")
        XCTAssertTrue(fileURL?.path.contains("HeyKidsWatchThis") == true, "URL should contain app folder")
    }
    
    func testLoadNonExistentFile() {
        let fileName = "nonexistent_file.json"
        
        let loadResult = fileManagerStorage.load(TestFileData.self, from: fileName, in: .caches)
        XCTAssertTrue(loadResult.isFailure, "Loading non-existent file should fail")
        
        if case .failure(let error) = loadResult {
            if case .fileNotFound = error {
                // Expected error type
            } else {
                XCTFail("Should return fileNotFound error, got: \(error)")
            }
        }
    }
    
    func testErrorHandling() {
        let invalidFileName = ""
        let testObject = TestFileData(name: "Error Test", value: 789)
        
        let saveResult = fileManagerStorage.save(testObject, to: invalidFileName, in: .caches)
        XCTAssertTrue(saveResult.isFailure, "Save with invalid filename should fail")
        
        if case .failure(let error) = saveResult {
            if case .invalidPath = error {
                // Expected error type
            } else {
                XCTFail("Should return invalidPath error, got: \(error)")
            }
        }
    }
    
    func testListFiles() {
        let testFiles = ["list_test_1.json", "list_test_2.json", "list_test_3.json"]
        let testObject = TestFileData(name: "List Test", value: 999)
        
        for fileName in testFiles {
            let saveResult = fileManagerStorage.save(testObject, to: fileName, in: .caches)
            XCTAssertTrue(saveResult.isSuccess, "Save should succeed for \(fileName)")
        }
        
        let listResult = fileManagerStorage.listFiles(in: .caches)
        XCTAssertTrue(listResult.isSuccess, "List files should succeed")
        
        if case .success(let files) = listResult {
            for testFile in testFiles {
                XCTAssertTrue(files.contains(testFile), "File list should contain \(testFile)")
            }
        }
    }
    
    private func cleanupTestFiles() {
        let testPrefixes = ["simple_test", "complex_movie_test", "exists_test", "delete_test", "list_test"]
        let directories: [StorageDirectory] = [.caches, .documents]
        
        for directory in directories {
            if let listResult = try? fileManagerStorage.listFiles(in: directory),
               case .success(let files) = listResult {
                for file in files {
                    if testPrefixes.contains(where: { file.hasPrefix($0) }) {
                        _ = fileManagerStorage.delete(fileName: file, in: directory)
                    }
                }
            }
        }
    }
}

struct TestFileData: Codable, Equatable {
    let name: String
    let value: Int
}
