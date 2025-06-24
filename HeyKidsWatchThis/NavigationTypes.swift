// NavigationTypes.swift - SURGICAL FIX
// Essential navigation types for HeyKidsWatchThis

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

// MARK: - Navigation State (FIXED - Added Hashable conformance)

enum NavigationRoute: Hashable {
    case movieDetail(UUID)  // Use UUID instead of MovieData for Hashable
    case memoryDetail(UUID)  // Use UUID instead of MemoryData for Hashable
    case createMemory(UUID)  // Use UUID instead of MovieData for Hashable
    case settings
    
    // Hashable conformance is automatic for enums with Hashable associated values
}
