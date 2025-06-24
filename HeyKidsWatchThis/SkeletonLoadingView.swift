import SwiftUI

struct SkeletonLoadingView<Content: View>: View {
    let isLoading: Bool
    let content: Content
    
    @State private var shimmerPhase: CGFloat = 0
    
    init(isLoading: Bool, @ViewBuilder content: () -> Content) {
        self.isLoading = isLoading
        self.content = content()
    }
    
    var body: some View {
        if isLoading {
            content
                .redacted(reason: .placeholder)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.primary.opacity(0.1),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerPhase)
                        .onAppear {
                            withAnimation(
                                .linear(duration: 1.5)
                                .repeatForever(autoreverses: false)
                            ) {
                                shimmerPhase = 400
                            }
                        }
                )
                .clipped()
        } else {
            content
        }
    }
}

extension View {
    func skeletonLoading(isLoading: Bool) -> some View {
        SkeletonLoadingView(isLoading: isLoading) {
            self
        }
    }
}
