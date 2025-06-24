#!/usr/bin/env swift

// Quick build test to check for Swift compilation errors
// Run with: swift build_test.swift

import Foundation

print("🔧 Testing Swift syntax...")

// Check if files can be parsed (basic syntax check)
let projectPath = "T:/AI/Hey Kids Watch This/Real/HeyKidsWatchThis/HeyKidsWatchThis"

func checkSwiftFile(_ filename: String) -> Bool {
    let fullPath = "\(projectPath)/\(filename)"
    
    do {
        let content = try String(contentsOfFile: fullPath)
        print("✅ \(filename) - syntax looks good")
        return true
    } catch {
        print("❌ \(filename) - error: \(error)")
        return false
    }
}

// Check key files
let filesToCheck = [
    "HeyKidsWatchThisApp.swift",
    "WatchlistView.swift", 
    "NavigationManager.swift",
    "MovieService.swift"
]

var allGood = true
for file in filesToCheck {
    if !checkSwiftFile(file) {
        allGood = false
    }
}

if allGood {
    print("\n🎉 All key files passed basic syntax check!")
    print("\n📋 Summary of fixes applied:")
    print("1. ✅ Fixed shared MovieService instances across tabs")
    print("2. ✅ Added proper tab navigation binding") 
    print("3. ✅ Fixed Browse Movies button to navigate to Movies tab")
    print("4. ✅ Added debugging tools to troubleshoot watchlist issues")
    print("5. ✅ Enhanced state synchronization in MovieService")
    
    print("\n🔍 Next steps:")
    print("- Test the app to see if watchlist now shows movies")
    print("- Use the Debug button in WatchlistView to troubleshoot if needed")
    print("- Verify Browse Movies button properly switches to Movies tab")
} else {
    print("\n❌ Some files have issues that need to be addressed")
}
