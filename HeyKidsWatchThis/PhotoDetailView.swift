//
//  PhotoDetailView.swift
//  HeyKidsWatchThis
//
//  TDD GREEN PHASE: Full-screen photo viewing component
//  This enables tap-to-view functionality for memory photos
//

import SwiftUI

/// Full-screen photo viewing with swipe navigation between photos
struct PhotoDetailView: View {
    let photos: [MemoryPhoto]
    let initialPhoto: MemoryPhoto
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    @State private var showingCaption = true
    
    init(photos: [MemoryPhoto], initialPhoto: MemoryPhoto) {
        self.photos = photos
        self.initialPhoto = initialPhoto
        self._currentIndex = State(initialValue: photos.firstIndex(of: initialPhoto) ?? 0)
    }
    
    var currentPhoto: MemoryPhoto {
        photos.indices.contains(currentIndex) ? photos[currentIndex] : photos[0]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if photos.count == 1 {
                    // Single photo view
                    SinglePhotoView(photo: currentPhoto)
                } else {
                    // Multiple photos with TabView for swiping
                    TabView(selection: $currentIndex) {
                        ForEach(0..<photos.count, id: \.self) { index in
                            SinglePhotoView(photo: photos[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                // Caption overlay
                if showingCaption, let caption = currentPhoto.caption, !caption.isEmpty {
                    VStack {
                        Spacer()
                        
                        Text(caption)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Rectangle()
                                    .fill(.black.opacity(0.7))
                                    .ignoresSafeArea(edges: .bottom)
                            )
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle(photos.count > 1 ? "Photo \(currentIndex + 1) of \(photos.count)" : "Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                if photos.count > 1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(showingCaption ? "Hide Caption" : "Show Caption") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingCaption.toggle()
                            }
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Individual photo view with zoom capability
struct SinglePhotoView: View {
    let photo: MemoryPhoto
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            if let uiImage = photo.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        // Pinch to zoom
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { value in
                                lastScale = scale
                                
                                // Limit zoom range
                                if scale < 1.0 {
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        lastScale = 1.0
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                } else if scale > 3.0 {
                                    withAnimation(.spring()) {
                                        scale = 3.0
                                        lastScale = 3.0
                                    }
                                }
                            }
                            .simultaneously(with:
                                // Drag to pan when zoomed
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { value in
                                        lastOffset = offset
                                        
                                        // Reset if dragged too far
                                        let maxOffset = geometry.size.width * 0.5
                                        if abs(offset.width) > maxOffset || abs(offset.height) > maxOffset {
                                            withAnimation(.spring()) {
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        }
                                    }
                            )
                    )
                    .onTapGesture(count: 2) {
                        // Double tap to zoom
                        withAnimation(.spring()) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            } else {
                // Fallback for failed photo loading
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Photo unavailable")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
        }
    }
}

// MARK: - Preview Support

#Preview("PhotoDetailView Single Photo") {
    let samplePhoto = MemoryPhoto(
        imageData: Data([1, 2, 3]),
        caption: "Family movie night - everyone loved it!"
    )
    
    return PhotoDetailView(
        photos: [samplePhoto],
        initialPhoto: samplePhoto
    )
}

#Preview("PhotoDetailView Multiple Photos") {
    let samplePhotos = [
        MemoryPhoto(imageData: Data([1, 2, 3]), caption: "Before the movie started"),
        MemoryPhoto(imageData: Data([4, 5, 6]), caption: "Popcorn and snacks ready"),
        MemoryPhoto(imageData: Data([7, 8, 9]), caption: "Everyone watching together"),
        MemoryPhoto(imageData: Data([10, 11, 12]), caption: nil)
    ]
    
    return PhotoDetailView(
        photos: samplePhotos,
        initialPhoto: samplePhotos[1]
    )
}
