// MinimalTestApp.swift - Ultra-minimal test to isolate the black screen issue
// Replace @main in HeyKidsWatchThisApp.swift with this temporarily

import SwiftUI

// MINIMAL TEST: Replace @main temporarily to test
// @main - COMMENTED OUT to avoid conflict with HeyKidsWatchThisApp
struct MinimalTestApp: App {
    var body: some Scene {
        WindowGroup {
            MinimalTestView()
        }
    }
}

struct MinimalTestView: View {
    @State private var counter = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("🎬 HeyKidsWatchThis")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Minimal Test - Counter: \(counter)")
                    .font(.title2)
                
                Button("Tap Me") {
                    counter += 1
                    print("Button tapped - counter is now \(counter)")
                }
                .buttonStyle(.borderedProminent)
                
                List {
                    ForEach(1...5, id: \.self) { index in
                        HStack {
                            Text("🎬")
                            Text("Test Movie \(index)")
                            Spacer()
                            Button("♥️") {
                                print("Heart tapped for movie \(index)")
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
            .padding()
            .navigationTitle("Test")
        }
        .onAppear {
            print("🎬 MinimalTestView appeared - SUCCESS!")
        }
    }
}

#Preview {
    MinimalTestView()
}
