#!/bin/bash
# QuickCompileTest.sh
# Test compilation with clean cache

echo "🧹 Cleaning build cache and testing compilation..."
echo "================================================="

cd "T:/AI/Hey Kids Watch This/Real/HeyKidsWatchThis"

echo "1. Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/HeyKidsWatchThis*

echo "2. Cleaning build folder..."
xcodebuild clean -scheme HeyKidsWatchThis -quiet

echo "3. Attempting build..."
xcodebuild build -scheme HeyKidsWatchThis -destination 'platform=iOS Simulator,name=iPhone 15 Pro' 2>&1 | head -20

echo ""
echo "✅ Test complete - check output above for any remaining errors"
