// DebugApp.swift - Minimal debug version to test app launching
// Use this as a fallback if main app still shows black screen

import SwiftUI

struct DebugApp: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "popcorn.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("HeyKidsWatchThis")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Debug Mode")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("App launched successfully")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("SwiftUI rendering working")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Navigation stack active")
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                Button("Test Navigation") {
                    print("🎬 Button tapped - navigation working!")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Debug")
        }
        .onAppear {
            print("🎬 DebugApp appeared successfully")
            print("🎬 SwiftUI environment is working")
        }
    }
}

// Alternative simple app entry point for debugging
struct DebugHeyKidsWatchThisApp: App {
    var body: some Scene {
        WindowGroup {
            DebugApp()
                .onAppear {
                    print("🎬 Debug app launched")
                }
        }
    }
}

#Preview {
    DebugApp()
}
