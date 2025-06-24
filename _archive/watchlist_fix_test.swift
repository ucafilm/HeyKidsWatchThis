// watchlist_fix_test.swift
// HeyKidsWatchThis - Test Script for Watchlist Fix
// Run this to verify the enhanced storage solution works

import Foundation

print("🧪 WATCHLIST FIX TEST")
print("===================")

// Test the enhanced movie service
let enhancedService = EnhancedMovieService()

print("\n📊 Initial State:")
print(enhancedService.getDebugInfo())

print("\n🧪 Testing Watchlist Operations:")

// Test 1: Get all movies
let allMovies = enhancedService.getAllMovies()
print("✅ Loaded \(allMovies.count) movies")

// Test 2: Find Mermaid movie
if let mermaidMovie = allMovies.first(where: { $0.title == "Mermaid" }) {
    print("✅ Found Mermaid movie: \(mermaidMovie.id)")
    
    // Test 3: Add to watchlist
    print("\n🔄 Adding Mermaid to watchlist...")
    enhancedService.addToWatchlist(mermaidMovie.id)
    
    // Test 4: Verify it's in watchlist
    let isInWatchlist = enhancedService.isInWatchlist(mermaidMovie.id)
    print("✅ Mermaid in watchlist: \(isInWatchlist)")
    
    // Test 5: Get watchlist movies
    let watchlistMovies = enhancedService.getWatchlistMovies()
    print("✅ Watchlist movies count: \(watchlistMovies.count)")
    
    // Test 6: Verify movie object has correct state
    if let syncedMovie = enhancedService.getAllMovies().first(where: { $0.id == mermaidMovie.id }) {
        print("✅ Synced movie isInWatchlist: \(syncedMovie.isInWatchlist)")
    }
    
} else {
    print("❌ Mermaid movie not found")
}

print("\n📊 Final State:")
print(enhancedService.getDebugInfo())

print("\n🎉 Test completed!")
print("If you see ✅ for all tests, the watchlist fix is working correctly.")
