// WatchlistView.swift
// HeyKidsWatchThis - FIXED VERSION
// Properly using shared MovieService from environment
// FIXED: No separate service instances

import SwiftUI
import Observation
import EventKit

struct WatchlistView: View {
    @Environment(MovieService.self) private var movieService
    @State private var showingMovieScheduler = false
    @State private var selectedMovie: MovieData?
    @State private var isLoading = false
    @State private var searchText = ""
    
    // Add this for testing
    @State private var testMessage = ""
    
    // Computed property that directly uses the shared movieService
    private var watchlistMovies: [MovieData] {
        let allMovies = movieService.getAllMovies()
        let watchlistIds = movieService.watchlist
        
        // DEBUG: Print diagnostic info
        print("🎬 WatchlistView Debug:")
        print("   All movies count: \(allMovies.count)")
        print("   Watchlist IDs count: \(watchlistIds.count)")
        print("   Watchlist IDs: \(watchlistIds.prefix(3))")
        
        // FIXED: Use the synchronized isInWatchlist property instead of service call
        let watchlistMovies = allMovies.filter { movie in
            let isInWatchlist = movie.isInWatchlist // Use synchronized property
            if isInWatchlist {
                print("   ✅ Movie '\(movie.title)' is in watchlist")
            }
            return isInWatchlist
        }
        
        print("   Final watchlist movies count: \(watchlistMovies.count)")
        
        if searchText.isEmpty {
            return watchlistMovies
        } else {
            return watchlistMovies.filter { movie in
                movie.title.localizedStandardContains(searchText) ||
                movie.genre.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    WatchlistLoadingView()
                } else if watchlistMovies.isEmpty {
                    WatchlistEmptyStateView()
                } else {
                    WatchlistContentView(
                        movies: watchlistMovies,
                        movieService: movieService,
                        onScheduleMovie: scheduleMovie
                    )
                }
            }
            .navigationTitle("Movie Queue")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Debug") {
                        DispatchQueue.main.async {
                            print("🔍 MANUAL DEBUG:")
                            print("   Movies count: \(movieService.getAllMovies().count)")
                            print("   Watchlist IDs: \(movieService.watchlist)")
                            
                            // Try adding a test movie to watchlist
                            if let firstMovie = movieService.getAllMovies().first {
                                print("   Adding test movie '\(firstMovie.title)' to watchlist...")
                                movieService.addToWatchlist(firstMovie.id)
                                print("   New watchlist IDs: \(movieService.watchlist)")
                            }
                        }
                    }
                    
                    Button("Refresh") {
                        movieService.refreshFromStorage()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search your movie queue")
            .refreshable {
                // Force refresh the movie service
                movieService.refreshFromStorage()
            }
            .fullScreenCover(isPresented: $showingMovieScheduler) {
                if let movie = selectedMovie {
                    // ✅ Use the final, stable scheduler view
                    MovieSchedulerView(
                        movie: movie,
                        movieService: movieService,
                        onDismiss: {
                            showingMovieScheduler = false
                            selectedMovie = nil
                        }
                    )
                }
            }
            .onAppear {
                movieService.refreshFromStorage()
            }
        }
    }
    
    private func scheduleMovie(_ movie: MovieData) {
        selectedMovie = movie
        // ✅ Keep the delay workaround for the iOS 17/18 presentation bug
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showingMovieScheduler = true
        }
    }
    
    // Helper function to format scheduled dates
    private func formattedScheduledDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Simplified Content View

struct WatchlistContentView: View {
    let movies: [MovieData]
    let movieService: MovieService
    let onScheduleMovie: (MovieData) -> Void
    
    var body: some View {
        List {
            // Quick Actions Section
            if !movies.isEmpty {
                Section {
                    WatchlistQuickActionsView(
                        movies: movies,
                        onScheduleMovie: onScheduleMovie
                    )
                }
                .listRowBackground(Color.clear)
            }
            
            // Movies Section
            Section("Your Movie Queue (\(movies.count))") {
                ForEach(movies) { movie in
                    WatchlistMovieRow(
                        movie: movie,
                        movieService: movieService,
                        onSchedule: { onScheduleMovie(movie) },
                        onRemove: { 
                            movieService.removeFromWatchlist(movie.id)
                        }
                    )
                }
            }
            
            // Statistics Section
            if !movies.isEmpty {
                Section("Statistics") {
                    WatchlistStatsView(movies: movies)
                }
            }
        }
    }
}

// MARK: - Quick Actions (Simplified)

struct WatchlistQuickActionsView: View {
    let movies: [MovieData]
    let onScheduleMovie: (MovieData) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Suggest for Tonight - but let them pick the actual time
                Button(action: {
                    if let randomMovie = movies.randomElement() {
                        onScheduleMovie(randomMovie)
                    }
                }) {
                    Label("Schedule Movie Night", systemImage: "calendar.badge.plus")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor, lineWidth: 1.5)
                        )
                }
                .disabled(movies.isEmpty)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Movie Row (Simplified)

struct WatchlistMovieRow: View {
    let movie: MovieData
    let movieService: MovieService
    let onSchedule: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Movie Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                Text(movie.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(movie.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 8) {
                            Text(movie.ageGroup.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(movie.genre)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let rating = movie.rating {
                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundStyle(.yellow)
                                    
                                    Text("\(rating, specifier: "%.1f")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    
                    // NEW: Show scheduled date if exists
                    if let scheduledDate = movie.scheduledDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Text("Scheduled: \(scheduledDate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                        }
                        }
                        
                        Spacer()
                    }
                
                // Streaming Services
                if !movie.streamingServices.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(movie.streamingServices.prefix(3), id: \.self) { service in
                            Text(service)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.opacity(0.1))
                                )
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        if movie.streamingServices.count > 3 {
                            Text("+\(movie.streamingServices.count - 3)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 8) {
                // Schedule Button
                Button(action: onSchedule) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.borderless)
                
                // Remove Button
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Remove", role: .destructive, action: onRemove)
        }
        .swipeActions(edge: .leading) {
            Button("Schedule", action: onSchedule)
                .tint(Color.accentColor)
        }
        .contextMenu {
            Button(action: onSchedule) {
                Label("Schedule Movie Night", systemImage: "calendar.badge.plus")
            }
            
            Button("Remove from Watchlist", role: .destructive, action: onRemove)
        }
    }
}

// MARK: - Statistics View (Simplified)

struct WatchlistStatsView: View {
    let movies: [MovieData]
    
    private var averageRating: Double {
        let ratings = movies.compactMap(\.rating)
        return ratings.isEmpty ? 0.0 : ratings.reduce(0, +) / Double(ratings.count)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            StatItem(
                value: "\(movies.count)",
                label: "Movies",
                icon: "film",
                color: .blue
            )
            
            StatItem(
                value: String(format: "%.1f", averageRating),
                label: "Avg Rating",
                icon: "star.fill",
                color: .yellow
            )
            
            StatItem(
                value: "\(movies.filter(\.isWatched).count)",
                label: "Watched",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.1))
        )
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty State

struct WatchlistEmptyStateView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
            
            VStack(spacing: 8) {
                Text("No Movies in Watchlist")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("Add movies to your watchlist to plan family movie nights")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            // RESTORED: Working tab navigation to Movies tab
            Button("Browse Movies") {
                navigationManager.navigateToMovies()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading State

struct WatchlistLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                .scaleEffect(1.2)
            
            Text("Loading your movie queue...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Movie Scheduler Sheet (Simplified for Debugging)

struct MovieSchedulerSheet: View {
    let movie: MovieData
    let onScheduled: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(movie: MovieData, onScheduled: @escaping () -> Void) {
        self.movie = movie
        self.onScheduled = onScheduled
        print("🎬 MovieSchedulerSheet init for: \(movie.title)")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Movie Header
                VStack(spacing: 16) {
                    Text(movie.emoji)
                        .font(.system(size: 80))
                    
                    Text("Schedule \(movie.title)")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Choose when to watch this movie")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Simple Action Buttons
                VStack(spacing: 16) {
                    Button("Tonight at 7 PM") {
                        print("🎬 Scheduling \(movie.title) for tonight")
                        onScheduled()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                    
                    Button("Tomorrow at 7 PM") {
                        print("🎬 Scheduling \(movie.title) for tomorrow")
                        onScheduled()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .font(.headline)
                    
                    Button("This Weekend") {
                        print("🎬 Scheduling \(movie.title) for weekend")
                        onScheduled()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .font(.headline)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
            .padding(24)
            .navigationTitle("Schedule Movie")
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
}

// MARK: - Removed duplicate MovieSchedulerView - using dedicated MovieSchedulerView.swift file instead

// MARK: - Preview

#if DEBUG
struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
            .environment(MovieService(dataProvider: MovieDataProvider()))
    }
}
#endif
