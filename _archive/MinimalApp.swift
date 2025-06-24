// MinimalApp.swift - Test version of your app
// Replace HeyKidsWatchThisApp temporarily with this:

import SwiftUI

@main
struct MinimalTestApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Minimal App Working")
                .onAppear {
                    print("✅ Minimal app launched successfully")
                }
        }
    }
}
