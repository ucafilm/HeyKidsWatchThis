// DiscussionLoadingView.swift - Missing Component Implementation
// HeyKidsWatchThis - Discussion Loading View
// Consistent loading state component following app patterns

import SwiftUI

struct DiscussionLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated discussion icon
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Image(systemName: "bubble.right.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.0 : 1.2)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(0.2),
                        value: isAnimating
                    )
                
                Image(systemName: "bubble.left.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(0.4),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 8) {
                Text("Loading Discussion Questions...")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Preparing age-appropriate questions for your family discussion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Progress indicator
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

// MARK: - Preview

#Preview {
    DiscussionLoadingView()
}
