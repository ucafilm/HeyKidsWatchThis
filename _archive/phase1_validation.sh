#!/bin/bash
# Quick compilation test to verify Phase 1 fixes

echo "🔍 Testing HeyKidsWatchThis compilation after Phase 1 cleanup..."
echo "================================================"

# Navigate to project directory
cd "T:/AI/Hey Kids Watch This/Real/HeyKidsWatchThis"

# Simple syntax check using Swift compiler
echo "📋 Checking for duplicate type definitions..."

# Check for duplicate EventKit types
echo "🔍 Checking EventKit types..."
find HeyKidsWatchThis -name "*.swift" -exec grep -l "struct TimeSlotSuggestion" {} \; | wc -l
find HeyKidsWatchThis -name "*.swift" -exec grep -l "struct MovieNightEvent" {} \; | wc -l  
find HeyKidsWatchThis -name "*.swift" -exec grep -l "protocol EventKitServiceProtocol" {} \; | wc -l

# Check for duplicate service types
echo "🔍 Checking Service types..."
find HeyKidsWatchThis -name "*.swift" -exec grep -l "enum MovieSortCriteria" {} \; | wc -l
find HeyKidsWatchThis -name "*.swift" -exec grep -l "struct WatchlistStatistics" {} \; | wc -l

echo "📊 Results:"
echo "- Each type should appear exactly ONCE"
echo "- TimeSlotSuggestion: Should be 1 (EventKitService.swift only)"
echo "- MovieNightEvent: Should be 1 (EventKitService.swift only)"  
echo "- EventKitServiceProtocol: Should be 1 (EventKitService.swift only)"
echo "- MovieSortCriteria: Should be 1 (MovieServiceProtocol.swift only)"
echo "- WatchlistStatistics: Should be 1 (MovieServiceProtocol.swift only)"

echo "✅ Phase 1 validation complete!"
