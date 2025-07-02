// NavigationTypes.swift - FINAL FIXED VERSION
// Central location for all navigation and alert types to prevent duplicates.

import Foundation

// MARK: - App Tab Enumeration

enum AppTab: String, CaseIterable {
    case movies = "Movies"
    case watchlist = "Watchlist"
    case memories = "Memories"
    case settings = "Settings"
    
    var systemImage: String {
        switch self {
        case .movies: return "popcorn"
        case .watchlist: return "heart"
        case .memories: return "photo.on.rectangle"
        case .settings: return "gear"
        }
    }
    
    var description: String {
        return rawValue
    }
}

// MARK: - Navigation State

enum NavigationRoute: Hashable {
    case movieDetail(UUID)
    case memoryDetail(UUID)
    case createMemory(UUID)
    case settings
}

// MARK: - FIX: Centralized Scheduler Alert Type

// This enum is now defined only here to be shared across the app.
enum SchedulerAlertType: Identifiable {
    case success(String)
    case failure(String)
    
    var id: String {
        switch self {
        case .success(let message): return "success-\(message)"
        case .failure(let message): return "failure-\(message)"
        }
    }
    
    var message: String {
        switch self {
        case .success(let msg): return msg
        case .failure(let msg): return msg
        }
    }
}
