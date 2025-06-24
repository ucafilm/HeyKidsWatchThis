// DiagnosticHelper.swift - Find out which loadWatchlist is being called
// Add this temporarily to debug the issue

import Foundation

extension MovieDataProvider {
    
    // Add this method to your MovieDataProvider to verify it's the right version
    func diagnosticInfo() -> String {
        let info = """
        🔍 DIAGNOSTIC INFO:
        - File: MovieDataProvider.swift
        - Version: DEFINITIVE FIX - NO CLEARING
        - Watchlist Key: stored_watchlist
        - Current watchlist count: \(loadWatchlist().count)
        - This version NEVER clears watchlist data
        """
        print(info)
        return info
    }
}

// Add this to help track down the issue
class DiagnosticWatchlistTracker {
    static func trackWatchlistCall(function: String = #function, file: String = #file) {
        print("🔍 WATCHLIST CALL TRACKER:")
        print("   Function: \(function)")
        print("   File: \(file.components(separatedBy: "/").last ?? file)")
        print("   Thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("   Stack:")
        Thread.callStackSymbols.prefix(5).forEach { symbol in
            print("     \(symbol)")
        }
    }
}
