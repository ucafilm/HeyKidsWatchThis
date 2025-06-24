#!/bin/bash
# HeyKidsWatchThis Compilation Fix Script
# Comprehensive fix for all identified issues

echo "🎬 HeyKidsWatchThis - Comprehensive Compilation Fix"
echo "=================================================="

PROJECT_PATH="T:/AI/Hey Kids Watch This/Real/HeyKidsWatchThis"
cd "$PROJECT_PATH"

echo "📋 STEP 1: Verify Required Files"
echo "================================="

# Check if TimeSlotSuggestionsView.swift exists
if [ -f "HeyKidsWatchThis/TimeSlotSuggestionsView.swift" ]; then
    echo "✅ TimeSlotSuggestionsView.swift exists"
else
    echo "❌ TimeSlotSuggestionsView.swift missing"
    exit 1
fi

# Check if EnhancedUIComponents.swift has required components
if grep -q "EnhancedPressableButton" "HeyKidsWatchThis/EnhancedUIComponents.swift"; then
    echo "✅ EnhancedPressableButton found in EnhancedUIComponents.swift"
else
    echo "❌ EnhancedPressableButton missing"
    exit 1
fi

echo "📋 STEP 2: Check for Duplicate Definitions"
echo "=========================================="

# Search for potential duplicate struct definitions
echo "Checking for duplicate View structures..."
DUPLICATE_STRUCTS=$(find HeyKidsWatchThis/ -name "*.swift" -exec grep -H "struct.*View" {} \; | grep -v ".xcassets" | sort)

echo "Found View structures:"
echo "$DUPLICATE_STRUCTS"

# Check specifically for TimeSlotSuggestionsView duplicates
TIMESLOT_DUPS=$(grep -r "struct TimeSlotSuggestionsView" HeyKidsWatchThis/ | grep -v ".xcassets")
if [ -n "$TIMESLOT_DUPS" ]; then
    echo "⚠️  TimeSlotSuggestionsView definitions found:"
    echo "$TIMESLOT_DUPS"
    
    # Count occurrences
    COUNT=$(echo "$TIMESLOT_DUPS" | wc -l)
    if [ $COUNT -gt 1 ]; then
        echo "❌ Multiple TimeSlotSuggestionsView definitions found ($COUNT)"
        echo "ACTION NEEDED: Remove duplicates from EnhancedWatchlistComponents.swift"
    else
        echo "✅ Only one TimeSlotSuggestionsView definition found"
    fi
else
    echo "❌ No TimeSlotSuggestionsView definitions found"
fi

echo "📋 STEP 3: Verify Imports"
echo "========================="

# Check for missing SwiftUI imports
echo "Checking for missing SwiftUI imports..."
find HeyKidsWatchThis/ -name "*.swift" -exec sh -c '
    file="$1"
    if grep -q "View\|Button\|Text\|VStack\|HStack" "$file" && ! grep -q "import SwiftUI" "$file"; then
        echo "⚠️  $file: Uses SwiftUI components but missing import SwiftUI"
    fi
' sh {} \;

# Check for missing UIKit imports where haptic feedback is used
echo "Checking for missing UIKit imports..."
find HeyKidsWatchThis/ -name "*.swift" -exec sh -c '
    file="$1"
    if grep -q "HapticFeedbackManager\|UIImpactFeedbackGenerator\|UISelectionFeedbackGenerator" "$file" && ! grep -q "import UIKit" "$file"; then
        echo "⚠️  $file: Uses haptic feedback but missing UIKit import"
    fi
' sh {} \;

echo "📋 STEP 4: Clean Build Test"
echo "==========================="

echo "Cleaning build folder..."
xcodebuild -project HeyKidsWatchThis.xcodeproj -scheme HeyKidsWatchThis clean > /dev/null 2>&1

echo "Attempting build..."
BUILD_OUTPUT=$(xcodebuild -project HeyKidsWatchThis.xcodeproj -scheme HeyKidsWatchThis build 2>&1)
BUILD_SUCCESS=$?

# Save build output to file
echo "$BUILD_OUTPUT" > build_output.log

if [ $BUILD_SUCCESS -eq 0 ]; then
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    echo "🎉 All compilation issues resolved!"
    echo "   Ready to continue with Phase 6 development."
else
    echo "❌ BUILD FAILED"
    echo ""
    echo "🔍 ERROR ANALYSIS:"
    echo "=================="
    
    # Extract and categorize errors
    ERRORS=$(echo "$BUILD_OUTPUT" | grep "error:")
    WARNINGS=$(echo "$BUILD_OUTPUT" | grep "warning:")
    
    if [ -n "$ERRORS" ]; then
        echo "COMPILATION ERRORS:"
        echo "$ERRORS" | head -10
        echo ""
        
        # Specific error patterns
        if echo "$ERRORS" | grep -q "Invalid redeclaration"; then
            echo "🔧 DUPLICATE DEFINITION ERRORS:"
            echo "$ERRORS" | grep "Invalid redeclaration"
            echo "   → Remove duplicate struct/class definitions"
            echo ""
        fi
        
        if echo "$ERRORS" | grep -q "Cannot find.*in scope"; then
            echo "🔧 MISSING COMPONENT ERRORS:"
            echo "$ERRORS" | grep "Cannot find.*in scope"
            echo "   → Check imports and component definitions"
            echo ""
        fi
        
        if echo "$ERRORS" | grep -q "Use of unresolved identifier"; then
            echo "🔧 UNRESOLVED IDENTIFIER ERRORS:"
            echo "$ERRORS" | grep "Use of unresolved identifier"
            echo "   → Verify all referenced components exist"
            echo ""
        fi
    fi
    
    if [ -n "$WARNINGS" ]; then
        echo "WARNINGS (review but not blocking):"
        echo "$WARNINGS" | head -5
        echo ""
    fi
    
    echo "📋 RECOMMENDED ACTIONS:"
    echo "======================"
    echo "1. Review build_output.log for detailed errors"
    echo "2. Fix duplicate definitions first"
    echo "3. Add missing imports"
    echo "4. Verify component definitions match usage"
    echo "5. Re-run this script after fixes"
fi

echo ""
echo "📋 STEP 5: File Verification Summary"
echo "===================================="

FILES_TO_CHECK=(
    "HeyKidsWatchThis/TimeSlotSuggestionsView.swift"
    "HeyKidsWatchThis/EnhancedUIComponents.swift"
    "HeyKidsWatchThis/EnhancedWatchlistComponents.swift"
    "HeyKidsWatchThis/ContentView.swift"
    "HeyKidsWatchThis/EventKitService.swift"
    "HeyKidsWatchThis/HapticFeedbackManager.swift"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo ""
echo "📋 NEXT STEPS:"
echo "=============="
if [ $BUILD_SUCCESS -eq 0 ]; then
    echo "✅ Project is ready for development!"
    echo "   → Continue with Phase 6 scheduling features"
    echo "   → Test the TimeSlot suggestions functionality"
    echo "   → Verify EventKit integration works properly"
else
    echo "🔧 Fix remaining compilation errors:"
    echo "   1. Check build_output.log for specific issues"
    echo "   2. Remove any remaining duplicate definitions"
    echo "   3. Add missing imports where needed"
    echo "   4. Verify all components are properly referenced"
    echo "   5. Run this script again after fixes"
fi

echo ""
echo "🎬 Compilation fix script completed!"
echo "   Build log saved to: build_output.log"
