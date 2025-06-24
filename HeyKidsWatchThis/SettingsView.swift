// SURGICAL FIX: Replace your SettingsView.swift with this corrected version
// This fixes all access control and redeclaration issues

import SwiftUI
import Foundation

// ============================================================================
// MARK: - FIX 1: UserPreferences (Correct Access Control)
// ============================================================================

@Observable
class UserPreferences {  // Remove 'public' - keep internal
    private let storage: UserDefaultsStorageProtocol
    
    private enum Keys {
        static let preferredTheme = "user_preferred_theme"
        static let defaultAgeGroup = "user_default_age_group"
        static let notificationsEnabled = "user_notifications_enabled"
        static let movieNightReminders = "user_movie_night_reminders"
        static let showWatchedMovies = "user_show_watched_movies"
        static let enableAnimations = "user_enable_animations"
        static let restrictContentByAge = "user_restrict_content_by_age"
        static let maxContentRating = "user_max_content_rating"
    }
    
    init(storage: UserDefaultsStorageProtocol) {  // Remove 'public'
        self.storage = storage
    }
    
    // MARK: - Properties (Internal access - no 'public')
    
    var preferredTheme: AppTheme {
        get {
            return storage.load(AppTheme.self, forKey: Keys.preferredTheme) ?? .system
        }
        set {
            _ = storage.save(newValue, forKey: Keys.preferredTheme)
        }
    }
    
    var defaultAgeGroup: AgeGroup {
        get {
            return storage.load(AgeGroup.self, forKey: Keys.defaultAgeGroup) ?? .littleKids
        }
        set {
            _ = storage.save(newValue, forKey: Keys.defaultAgeGroup)
        }
    }
    
    var notificationsEnabled: Bool {
        get {
            return storage.load(Bool.self, forKey: Keys.notificationsEnabled) ?? true
        }
        set {
            _ = storage.save(newValue, forKey: Keys.notificationsEnabled)
        }
    }
    
    var movieNightReminders: Bool {
        get {
            return storage.load(Bool.self, forKey: Keys.movieNightReminders) ?? true
        }
        set {
            _ = storage.save(newValue, forKey: Keys.movieNightReminders)
        }
    }
    
    var showWatchedMovies: Bool {
        get {
            return storage.load(Bool.self, forKey: Keys.showWatchedMovies) ?? true
        }
        set {
            _ = storage.save(newValue, forKey: Keys.showWatchedMovies)
        }
    }
    
    var enableAnimations: Bool {
        get {
            return storage.load(Bool.self, forKey: Keys.enableAnimations) ?? true
        }
        set {
            _ = storage.save(newValue, forKey: Keys.enableAnimations)
        }
    }
    
    var restrictContentByAge: Bool {
        get {
            return storage.load(Bool.self, forKey: Keys.restrictContentByAge) ?? false
        }
        set {
            _ = storage.save(newValue, forKey: Keys.restrictContentByAge)
        }
    }
    
    var maxContentRating: Double {
        get {
            return storage.load(Double.self, forKey: Keys.maxContentRating) ?? 5.0
        }
        set {
            let clampedValue = max(1.0, min(5.0, newValue))
            _ = storage.save(clampedValue, forKey: Keys.maxContentRating)
        }
    }
}

// ============================================================================
// MARK: - FIX 2: SettingsViewModel (Correct Access Control)
// ============================================================================

@MainActor
@Observable
class SettingsViewModel {  // Remove 'public'
    let settingsService: SettingsServiceProtocol  // Remove 'public'
    let userPreferences: UserPreferences  // Remove 'public'
    
    // UI State
    var isLoading = false
    var errorMessage: String?
    var selectedSection: SettingsSection = .preferences
    var showingResetConfirmation = false
    var showingExportSheet = false
    var showingImportSheet = false
    
    init(settingsService: SettingsServiceProtocol, userPreferences: UserPreferences) {  // Remove 'public'
        self.settingsService = settingsService
        self.userPreferences = userPreferences
    }
    
    // MARK: - Methods (Internal access)
    
    func selectSection(_ section: SettingsSection) {
        selectedSection = section
    }
    
    func clearCache() async {
        isLoading = true
        errorMessage = nil
        
        let result = settingsService.clearCache()
        
        switch result {
        case .success:
            errorMessage = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func resetApp() async {
        isLoading = true
        errorMessage = nil
        
        let result = settingsService.resetAppData()
        
        switch result {
        case .success:
            errorMessage = nil
            showingResetConfirmation = false
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func exportUserData() async -> Result<String, SettingsError> {
        isLoading = true
        let result = settingsService.exportUserData()
        isLoading = false
        
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success:
            errorMessage = nil
        }
        
        return result
    }
    
    func importUserData(_ data: String) async -> Result<Void, SettingsError> {
        isLoading = true
        let result = settingsService.importUserData(data)
        isLoading = false
        
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success:
            errorMessage = nil
        }
        
        return result
    }
    
    func showResetConfirmation() {
        showingResetConfirmation = true
    }
    
    func cancelReset() {
        showingResetConfirmation = false
    }
    
    func showExportSheet() {
        showingExportSheet = true
    }
    
    func showImportSheet() {
        showingImportSheet = true
    }
    
    func calculateStorageUsage() -> StorageUsage {
        return settingsService.calculateStorageUsage()
    }
    
    // MARK: - Bindings
    
    var themeBinding: Binding<AppTheme> {
        Binding(
            get: { self.userPreferences.preferredTheme },
            set: { self.userPreferences.preferredTheme = $0 }
        )
    }
    
    var defaultAgeGroupBinding: Binding<AgeGroup> {
        Binding(
            get: { self.userPreferences.defaultAgeGroup },
            set: { self.userPreferences.defaultAgeGroup = $0 }
        )
    }
    
    var notificationsBinding: Binding<Bool> {
        Binding(
            get: { self.userPreferences.notificationsEnabled },
            set: { self.userPreferences.notificationsEnabled = $0 }
        )
    }
    
    var movieNightRemindersBinding: Binding<Bool> {
        Binding(
            get: { self.userPreferences.movieNightReminders },
            set: { self.userPreferences.movieNightReminders = $0 }
        )
    }
    
    var showWatchedMoviesBinding: Binding<Bool> {
        Binding(
            get: { self.userPreferences.showWatchedMovies },
            set: { self.userPreferences.showWatchedMovies = $0 }
        )
    }
    
    var enableAnimationsBinding: Binding<Bool> {
        Binding(
            get: { self.userPreferences.enableAnimations },
            set: { self.userPreferences.enableAnimations = $0 }
        )
    }
    
    var restrictContentBinding: Binding<Bool> {
        Binding(
            get: { self.userPreferences.restrictContentByAge },
            set: { self.userPreferences.restrictContentByAge = $0 }
        )
    }
    
    var maxContentRatingBinding: Binding<Double> {
        Binding(
            get: { self.userPreferences.maxContentRating },
            set: { self.userPreferences.maxContentRating = $0 }
        )
    }
}

// ============================================================================
// MARK: - FIX 3: Supporting Types (Internal access)
// ============================================================================

enum AppTheme: String, CaseIterable, Codable {  // Remove 'public'
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

enum SettingsSection: String, CaseIterable {  // Remove 'public'
    case preferences = "preferences"
    case dataManagement = "dataManagement"
    case about = "about"
    
    var title: String {
        switch self {
        case .preferences: return "Preferences"
        case .dataManagement: return "Data Management"
        case .about: return "About"
        }
    }
    
    var icon: String {
        switch self {
        case .preferences: return "gearshape"
        case .dataManagement: return "externaldrive"
        case .about: return "info.circle"
        }
    }
}

protocol SettingsServiceProtocol {  // Remove 'public'
    func clearCache() -> Result<Void, SettingsError>
    func resetAppData() -> Result<Void, SettingsError>
    func exportUserData() -> Result<String, SettingsError>
    func importUserData(_ data: String) -> Result<Void, SettingsError>
    func getAppInformation() -> AppInformation
    func calculateStorageUsage() -> StorageUsage
}

enum SettingsError: Error, Equatable {  // Remove 'public'
    case operationFailed(String)
    case invalidData(String)
    case storageError(String)
    
    var localizedDescription: String {
        switch self {
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .storageError(let message):
            return "Storage error: \(message)"
        }
    }
}

struct AppInformation {  // Remove 'public'
    let appName: String
    let version: String
    let buildNumber: String
    let privacyPolicyURL: String
    let termsOfServiceURL: String
    let supportEmail: String
    
    init(appName: String, version: String, buildNumber: String, privacyPolicyURL: String, termsOfServiceURL: String, supportEmail: String) {
        self.appName = appName
        self.version = version
        self.buildNumber = buildNumber
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfServiceURL = termsOfServiceURL
        self.supportEmail = supportEmail
    }
}

struct StorageUsage {  // Remove 'public'
    let totalSizeBytes: Int64
    let itemCount: Int
    let categories: [StorageCategory]
    
    init(totalSizeBytes: Int64, itemCount: Int, categories: [StorageCategory]) {
        self.totalSizeBytes = totalSizeBytes
        self.itemCount = itemCount
        self.categories = categories
    }
}

struct StorageCategory {  // Remove 'public'
    let name: String
    let sizeBytes: Int64
    let itemCount: Int
    
    init(name: String, sizeBytes: Int64, itemCount: Int) {
        self.name = name
        self.sizeBytes = sizeBytes
        self.itemCount = itemCount
    }
}

// ============================================================================
// MARK: - FIX 4: SettingsService Implementation
// ============================================================================

class SettingsService: SettingsServiceProtocol {  // Remove 'public'
    private let storage: UserDefaultsStorageProtocol
    private let userPreferences: UserPreferences
    
    init(storage: UserDefaultsStorageProtocol, userPreferences: UserPreferences) {  // Remove 'public'
        self.storage = storage
        self.userPreferences = userPreferences
    }
    
    func clearCache() -> Result<Void, SettingsError> {
        let cacheKeys = [
            "analytics_cache",
            "temp_storage",
            "cached_search_results",
            "image_cache_data"
        ]
        
        for key in cacheKeys {
            if storage.exists(forKey: key) {
                storage.remove(forKey: key)
            }
        }
        
        return .success(())
    }
    
    func resetAppData() -> Result<Void, SettingsError> {
        storage.removeAll()
        
        userPreferences.preferredTheme = .system
        userPreferences.defaultAgeGroup = .littleKids
        userPreferences.notificationsEnabled = true
        userPreferences.movieNightReminders = true
        userPreferences.showWatchedMovies = true
        userPreferences.enableAnimations = true
        userPreferences.restrictContentByAge = false
        userPreferences.maxContentRating = 5.0
        
        return .success(())
    }
    
    func exportUserData() -> Result<String, SettingsError> {
        do {
            var exportData: [String: Any] = [:]
            
            let preferences: [String: Any] = [
                "preferredTheme": userPreferences.preferredTheme.rawValue,
                "defaultAgeGroup": userPreferences.defaultAgeGroup.rawValue,
                "notificationsEnabled": userPreferences.notificationsEnabled,
                "movieNightReminders": userPreferences.movieNightReminders,
                "showWatchedMovies": userPreferences.showWatchedMovies,
                "enableAnimations": userPreferences.enableAnimations,
                "restrictContentByAge": userPreferences.restrictContentByAge,
                "maxContentRating": userPreferences.maxContentRating
            ]
            exportData["user_preferences"] = preferences
            
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return .failure(.operationFailed("Failed to convert data to string"))
            }
            
            return .success(jsonString)
        } catch {
            return .failure(.operationFailed("Failed to export data: \(error.localizedDescription)"))
        }
    }
    
    func importUserData(_ data: String) -> Result<Void, SettingsError> {
        do {
            guard let jsonData = data.data(using: .utf8) else {
                return .failure(.invalidData("Invalid JSON string"))
            }
            
            guard let importData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                return .failure(.invalidData("Invalid JSON format"))
            }
            
            if let preferences = importData["user_preferences"] as? [String: Any] {
                if let themeString = preferences["preferredTheme"] as? String,
                   let theme = AppTheme(rawValue: themeString) {
                    userPreferences.preferredTheme = theme
                }
                
                if let ageGroupString = preferences["defaultAgeGroup"] as? String,
                   let ageGroup = AgeGroup(rawValue: ageGroupString) {
                    userPreferences.defaultAgeGroup = ageGroup
                }
                
                if let notifications = preferences["notificationsEnabled"] as? Bool {
                    userPreferences.notificationsEnabled = notifications
                }
                
                if let reminders = preferences["movieNightReminders"] as? Bool {
                    userPreferences.movieNightReminders = reminders
                }
                
                if let showWatched = preferences["showWatchedMovies"] as? Bool {
                    userPreferences.showWatchedMovies = showWatched
                }
                
                if let animations = preferences["enableAnimations"] as? Bool {
                    userPreferences.enableAnimations = animations
                }
                
                if let restrict = preferences["restrictContentByAge"] as? Bool {
                    userPreferences.restrictContentByAge = restrict
                }
                
                if let rating = preferences["maxContentRating"] as? Double {
                    userPreferences.maxContentRating = rating
                }
            }
            
            return .success(())
        } catch {
            return .failure(.invalidData("Failed to parse import data: \(error.localizedDescription)"))
        }
    }
    
    func getAppInformation() -> AppInformation {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        
        return AppInformation(
            appName: "HeyKidsWatchThis",
            version: version,
            buildNumber: buildNumber,
            privacyPolicyURL: "https://example.com/privacy",
            termsOfServiceURL: "https://example.com/terms",
            supportEmail: "support@heykidswatchthis.com"
        )
    }
    
    func calculateStorageUsage() -> StorageUsage {
        var totalSize: Int64 = 0
        var itemCount = 0
        var categories: [StorageCategory] = []
        
        let preferencesSize: Int64 = 256
        let preferencesCount = 8
        categories.append(StorageCategory(name: "Preferences", sizeBytes: preferencesSize, itemCount: preferencesCount))
        totalSize += preferencesSize
        itemCount += preferencesCount
        
        return StorageUsage(
            totalSizeBytes: totalSize,
            itemCount: itemCount,
            categories: categories
        )
    }
}

// ============================================================================
// MARK: - FIX 5: Main Settings View
// ============================================================================

struct SettingsView: View {  // Remove 'public' - this was causing redeclaration
    @State private var viewModel: SettingsViewModel
    private let storage: UserDefaultsStorageProtocol
    
    init(storage: UserDefaultsStorageProtocol = UserDefaultsStorage()) {  // Remove 'public'
        self.storage = storage
        
        let userPreferences = UserPreferences(storage: storage)
        let settingsService = SettingsService(storage: storage, userPreferences: userPreferences)
        let viewModel = SettingsViewModel(settingsService: settingsService, userPreferences: userPreferences)
        
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(SettingsSection.allCases, id: \.self) { section in
                    NavigationLink(destination: detailView(for: section)) {
                        HStack {
                            Image(systemName: section.icon)
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text(section.title)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private func detailView(for section: SettingsSection) -> some View {
        switch section {
        case .preferences:
            PreferencesView(viewModel: viewModel)
        case .dataManagement:
            DataManagementView(viewModel: viewModel)
        case .about:
            AboutView()
        }
    }
}

/*
 ACCESS CONTROL FIX COMPLETE
 
 KEY CHANGES MADE:
 ✅ Removed all 'public' keywords - using internal access
 ✅ Fixed redeclaration conflicts
 ✅ Maintained functionality while fixing access issues
 ✅ Compatible with your existing architecture
 
 This should resolve all 10 build errors shown in your screenshot.
 */
