// MemoryDetailView.swift
// HeyKidsWatchThis - Memory Detail View
// Following established enhanced detail view patterns

import SwiftUI

struct MemoryDetailView: View {
    let memory: MemoryData
    @Bindable var memoryViewModel: MemoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDiscussion = false
    @State private var showingShareSheet = false
    
    private var movie: MovieData? {
        memoryViewModel.getMovie(for: memory)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Movie Header Section
                    MovieHeaderSection(movie: movie, memory: memory)
                    
                    Divider()
                    
                    // Memory Details Section
                    MemoryDetailsSection(memory: memory)
                    
                    if !memory.discussionAnswers.isEmpty {
                        Divider()
                        
                        // Discussion Section
                        DiscussionSection(memory: memory)
                    }
                    
                    // NEW: Photos Section
                    if !memory.photos.isEmpty {
                        Divider()
                        
                        PhotosSection(memory: memory, memoryViewModel: memoryViewModel)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Memory Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingDiscussion = true
                        } label: {
                            Label("Add Discussion", systemImage: "bubble.left.and.bubble.right")
                        }
                        
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("Share Memory", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            deleteMemory()
                        } label: {
                            Label("Delete Memory", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingDiscussion) {
            DiscussionView(
                memory: memory,
                memoryViewModel: memoryViewModel
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView(memory: memory, movie: movie)
        }
    }
    
    private func deleteMemory() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            memoryViewModel.deleteMemory(memory)
            dismiss()
        }
    }
}

// MARK: - Movie Header Section

struct MovieHeaderSection: View {
    let movie: MovieData?
    let memory: MemoryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(movie?.emoji ?? "🎬")
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie?.title ?? "Unknown Movie")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let movie = movie {
                        Text("\(movie.year) • \(movie.genre)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Rating Display
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= memory.rating ? "star.fill" : "star")
                        .foregroundColor(star <= memory.rating ? .yellow : .gray)
                        .font(.title3)
                }
                
                Spacer()
                
                Text(formatDate(memory.watchDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Movie Details
            if let movie = movie {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Age Group
                        DetailChipView(
                            text: movie.ageGroup.description,
                            color: .blue,
                            icon: "person.3"
                        )
                        
                        // Streaming Services
                        ForEach(movie.streamingServices, id: \.self) { service in
                            DetailChipView(
                                text: service,
                                color: .purple,
                                icon: "play.tv"
                            )
                        }
                        
                        // Rating - FIXED: Using String(format:) instead of specifier parameter
                        if let rating = movie.rating {
                            DetailChipView(
                                text: String(format: "%.1f", rating) + "⭐",
                                color: .orange,
                                icon: nil
                            )
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// MARK: - Memory Details Section

struct MemoryDetailsSection: View {
    let memory: MemoryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Experience")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Rating: \(memory.rating) out of 5 stars")
                    .font(.subheadline)
                
                if let notes = memory.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(notes)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                // Memory Statistics
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Watched")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(timeAgo(from: memory.watchDate))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    if !memory.discussionAnswers.isEmpty {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Discussion")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(memory.discussionAnswers.count) answer\(memory.discussionAnswers.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Photos Section

struct PhotosSection: View {
    let memory: MemoryData
    @Bindable var memoryViewModel: MemoryViewModel
    
    @State private var showingPhotoDetail: MemoryPhoto?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
                    .font(.headline)
                
                Spacer()
                
                Text("\(memory.photos.count) photo\(memory.photos.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            PhotoGridView(
                photos: memory.photos,
                onPhotoTap: { photo in
                    showingPhotoDetail = photo
                },
                onPhotoDelete: { photo in
                    deletePhoto(photo)
                }
            )
        }
        .fullScreenCover(item: $showingPhotoDetail) { photo in
            PhotoDetailView(
                photos: memory.photos,
                initialPhoto: photo
            )
        }
    }
    
    private func deletePhoto(_ photo: MemoryPhoto) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            memoryViewModel.removePhotoFromMemory(photo, from: memory)
            HapticFeedbackManager.shared.triggerSuccess()
        }
    }
}

struct DiscussionSection: View {
    let memory: MemoryData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Family Discussion")
                    .font(.headline)
                
                Spacer()
                
                Text("\(memory.discussionAnswers.count) response\(memory.discussionAnswers.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(memory.discussionAnswers) { answer in
                    DiscussionAnswerRowView(answer: answer)
                }
            }
        }
    }
}

// MARK: - Discussion Answer Row View

struct DiscussionAnswerRowView: View {
    let answer: DiscussionAnswer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Age \(answer.childAge)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                
                Spacer()
            }
            
            Text(answer.response)
                .font(.body)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// MARK: - Detail Chip View

struct DetailChipView: View {
    let text: String
    let color: Color
    let icon: String?
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

// MARK: - Share Sheet View

struct ShareSheetView: View {
    let memory: MemoryData
    let movie: MovieData?
    @Environment(\.dismiss) private var dismiss
    
    private var shareText: String {
        var text = ""
        
        if let movie = movie {
            text += "🎬 \(movie.title) (\(movie.year))\n"
        }
        
        text += "⭐ Rating: \(memory.rating)/5 stars\n"
        text += "📅 Watched: \(formatDate(memory.watchDate))\n"
        
        if let notes = memory.notes, !notes.isEmpty {
            text += "\n💭 \(notes)\n"
        }
        
        if !memory.discussionAnswers.isEmpty {
            text += "\n💬 Family had \(memory.discussionAnswers.count) discussion\(memory.discussionAnswers.count == 1 ? "" : "s") about this movie!\n"
        }
        
        text += "\n#FamilyMovieNight #HeyKidsWatchThis"
        
        return text
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share Preview")
                        .font(.headline)
                    
                    Text(shareText)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                // Share Options
                VStack(spacing: 16) {
                    Button {
                        shareToSocialMedia()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share to Social Media")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Button {
                        copyToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                            Text("Copy to Clipboard")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Share Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareToSocialMedia() {
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
        
        dismiss()
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = shareText
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    MemoryDetailView(
        memory: MemoryData(
            movieId: UUID(),
            watchDate: Date(),
            rating: 5,
            notes: "Amazing family movie night! The kids loved every minute of it.",
            discussionAnswers: [
                DiscussionAnswer(
                    questionId: UUID(),
                    response: "I loved the part where the characters became friends!",
                    childAge: 7
                )
            ]
        ),
        memoryViewModel: MemoryViewModel(
            memoryService: MemoryService(dataProvider: MemoryDataProvider()),
            movieService: MovieService(dataProvider: MovieDataProvider())
        )
    )
}
