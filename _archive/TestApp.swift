// TestApp.swift - Minimal version for debugging SIGTERM
// Copy this into a new Swift file to test

import SwiftUI

struct TestContentView: View {
    var body: some View {
        TabView {
            Text("Movies Tab Working")
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            
            Text("Watchlist Tab Working")
                .tabItem {
                    Label("Watchlist", systemImage: "heart")
                }
        }
        .onAppear {
            print("✅ TestContentView appeared successfully")
        }
    }
}

// Temporary test - replace your ContentView with this:
// struct ContentView: View {
//     var body: some View {
//         TestContentView()
//     }
// }

#Preview {
    TestContentView()
}
