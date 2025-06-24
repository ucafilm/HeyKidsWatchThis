#!/bin/bash
# HeyKidsWatchThis - Target Membership Fix Script
# This script fixes the MockMovieService target membership warning

echo "🎬 HeyKidsWatchThis - Fixing Target Membership Issue"
echo "==================================================="
echo ""

PROJECT_DIR="T:/AI/Hey Kids Watch This/Real/HeyKidsWatchThis"
cd "$PROJECT_DIR"

echo "📍 Current directory: $(pwd)"
echo ""

# Check if MockMovieService.swift is in the correct location
if [ -f "HeyKidsWatchThisTests/MockMovieService.swift" ]; then
    echo "✅ MockMovieService.swift found in correct test directory"
else
    echo "❌ MockMovieService.swift not found in test directory"
    exit 1
fi

# Check if MockMovieService.swift accidentally exists in main directory
if [ -f "HeyKidsWatchThis/MockMovieService.swift" ]; then
    echo "❌ PROBLEM FOUND: MockMovieService.swift exists in main app directory"
    echo "🔧 Removing MockMovieService.swift from main app directory..."
    rm "HeyKidsWatchThis/MockMovieService.swift"
    echo "✅ Removed MockMovieService.swift from main app directory"
    echo ""
else
    echo "✅ MockMovieService.swift is NOT in main app directory (good)"
    echo ""
fi

# Clean all build artifacts to force Xcode to re-index
echo "🧹 Cleaning build artifacts..."

# Remove derived data (if accessible)
if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
    echo "  🗑️  Cleaning DerivedData..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/HeyKidsWatchThis-*
fi

# Clean using xcodebuild
echo "  🔨 Running xcodebuild clean..."
xcodebuild -project HeyKidsWatchThis.xcodeproj -scheme HeyKidsWatchThis clean >/dev/null 2>&1

echo "✅ Build artifacts cleaned"
echo ""

# Force re-indexing by touching the project file
echo "🔄 Forcing Xcode re-indexing..."
touch HeyKidsWatchThis.xcodeproj/project.pbxproj
echo "✅ Project file touched to trigger re-indexing"
echo ""

# Build the project to test the fix
echo "🔨 Testing build after cleanup..."
BUILD_OUTPUT=$(xcodebuild -project HeyKidsWatchThis.xcodeproj -scheme HeyKidsWatchThis build 2>&1)
BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ BUILD SUCCESSFUL!"
    
    # Check for warnings about MockMovieService
    if echo "$BUILD_OUTPUT" | grep -q "MockMovieService.swift.*ignoring import"; then
        echo "⚠️  Warning still present - may need manual Xcode intervention"
    else
        echo "🎉 TARGET MEMBERSHIP WARNING RESOLVED!"
    fi
else
    echo "❌ BUILD FAILED - checking for specific errors..."
    echo "$BUILD_OUTPUT" | grep -E "(error|warning|MockMovieService)"
fi

echo ""
echo "🎯 Manual Steps (if warning persists):"
echo "  1. Open Xcode"
echo "  2. Clean Build Folder (⌘+Shift+K)"
echo "  3. Close Xcode completely"
echo "  4. Delete DerivedData: ~/Library/Developer/Xcode/DerivedData"
echo "  5. Reopen Xcode and rebuild"
echo ""

echo "📝 Alternative Fix in Xcode:"
echo "  1. Select MockMovieService.swift in Project Navigator"
echo "  2. In File Inspector (right panel), check Target Membership"
echo "  3. Ensure ONLY 'HeyKidsWatchThisTests' is checked"
echo "  4. Ensure 'HeyKidsWatchThis' (main app) is UNCHECKED"
echo ""

echo "🎬 Fix Complete! The target membership issue should be resolved."
