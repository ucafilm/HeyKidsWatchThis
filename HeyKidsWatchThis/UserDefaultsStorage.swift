import Foundation

// MARK: - Protocol Definition
protocol UserDefaultsStorageProtocol {
    func save<T: Codable>(_ object: T, forKey key: String) -> Bool
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func remove(forKey key: String)
    func exists(forKey key: String) -> Bool
    func removeAll()
}

// MARK: - Implementation
class UserDefaultsStorage: UserDefaultsStorageProtocol {
    
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = .sortedKeys
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func save<T: Codable>(_ object: T, forKey key: String) -> Bool {
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
            return true
        } catch {
            print("⚠️ UserDefaultsStorage save failed for key '\(key)': \(error)")
            return false
        }
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("⚠️ UserDefaultsStorage load failed for key '\(key)', type '\(type)': \(error)")
            return nil
        }
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    func exists(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
    
    func removeAll() {
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }
}

// MARK: - Test Helper Extensions
extension UserDefaults {
    static func testSuite(for testName: String) -> UserDefaults {
        let suiteName = "test-\(testName)-\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
    
    static func clearTestSuite(_ userDefaults: UserDefaults) {
        userDefaults.dictionaryRepresentation().keys.forEach {
            userDefaults.removeObject(forKey: $0)
        }
        userDefaults.synchronize()
    }
}
