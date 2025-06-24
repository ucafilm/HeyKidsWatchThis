// SimplePhotoTest.swift
// Minimal photo loading test to isolate the issue

import SwiftUI
import PhotosUI

struct SimplePhotoTest: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Simple Photo Test")
                .font(.title)
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 3,
                matching: .images
            ) {
                Text("Select Photos")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text("Selected: \(selectedItems.count)")
            Text("Loaded: \(loadedImages.count)")
            
            if !loadedImages.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            loadImages(newItems)
        }
    }
    
    private func loadImages(_ items: [PhotosPickerItem]) {
        loadedImages.removeAll()
        
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        loadedImages.append(image)
                    }
                }
            }
        }
    }
}

#Preview {
    SimplePhotoTest()
}
