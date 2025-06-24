#!/bin/bash
# BuildValidation.sh
# Quick script to test compilation fixes

echo "🔨 Testing HeyKidsWatchThis Compilation Fixes"
echo "=============================================="

# Navigate to project directory
cd "T:\AI\Hey Kids Watch This\Real\HeyKidsWatchThis"

echo "📁 Current directory: $(pwd)"
echo ""

echo "🧹 Cleaning build folder..."
xcodebuild clean -scheme HeyKidsWatchThis -quiet

echo "🔨 Building project..."
BUILD_RESULT=$(xcodebuild build -scheme HeyKidsWatchThis -destination 'platform=iOS Simulator,name=iPhone 15 Pro' 2>&1)

if echo "$BUILD_RESULT" | grep -q "BUILD SUCCEEDED"; then
    echo "✅ BUILD SUCCEEDED!"
    echo ""
    echo "🧪 Running basic tests..."
    TEST_RESULT=$(xcodebuild test -scheme HeyKidsWatchThis -only-testing:HeyKidsWatchThisTests/BasicCompilationTests -destination 'platform=iOS Simulator,name=iPhone 15 Pro' 2>&1)
    
    if echo "$TEST_RESULT" | grep -q "Test Suite 'BasicCompilationTests' passed"; then
        echo "✅ TESTS PASSED!"
        echo ""
        echo "🎉 Phase 1 TDD Compilation Fix: COMPLETE"
        echo "📱 App is ready to run in simulator"
        echo "🚀 Ready to proceed to Phase 2"
    else
        echo "⚠️ Build succeeded but tests failed"
        echo "🔍 Check test output for details"
    fi
else
    echo "❌ BUILD FAILED"
    echo "🔍 Compilation errors found:"
    echo "$BUILD_RESULT" | grep -E "(error:|Error:|BUILD FAILED)"
    echo ""
    echo "🛠 Additional fixes needed"
fi

echo ""
echo "📊 Build Summary:"
echo "- Total errors: $(echo "$BUILD_RESULT" | grep -c "error:")"
echo "- Total warnings: $(echo "$BUILD_RESULT" | grep -c "warning:")"
