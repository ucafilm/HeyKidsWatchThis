// WatchlistView.swift
// HEYKIDSWATCHTHIS - FINAL FIXED VERSION
// Correctly presents the CalendarIntegratedMovieScheduler

import SwiftUI
import Observation
import EventKit

struct WatchlistView: View {
    @Environment(MovieService.self) private var movieService
    
    // This environment object is now needed for the correct scheduler
    @EnvironmentObject private var calendarService: CalendarService
    
    @State private var showingMovieScheduler = false
    @State private var selectedMovie: MovieData?
    @State private var isLoading = false
    @State private var searchText = ""
    
    private var watchlistMovies: [MovieData] {
        let allMovies = movieService.getAllMovies()
        
        // Use the synchronized isInWatchlist property
        let watchlistMovies = allMovies.filter { $0.isInWatchlist }
        
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
                    Button("Refresh") {
                        // This will force a reload of the watchlist from storage
                        if let service = movieService as? EnhancedMovieService {
                            service.refreshFromStorage()
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search your movie queue")
            .refreshable {
                if let service = movieService as? EnhancedMovieService {
                    service.refreshFromStorage()
                }
            }
            .fullScreenCover(isPresented: $showingMovieScheduler) {
                // ✅ FIX: Present the correct, fully-functional scheduler view
                if let movie = selectedMovie {
                    CalendarIntegratedMovieScheduler(
                        movie: movie,
                        movieService: movieService,
                        onDismiss: {
                            showingMovieScheduler = false
                            selectedMovie = nil
                        }
                    )
                    // The CalendarService is already in the environment from HeyKidsWatchThisApp
                }
            }
            .onAppear {
                if let service = movieService as? EnhancedMovieService {
                    service.refreshFromStorage()
                }
            }
        }
    }
    
    private func scheduleMovie(_ movie: MovieData) {
        selectedMovie = movie
        // Keep the delay workaround for the iOS 17/18 presentation bug
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showingMovieScheduler = true
        }
    }
}


// MARK: - Content Views (No changes needed below)

struct WatchlistContentView: View {
    let movies: [MovieData]
    let movieService: MovieServiceProtocol
    let onScheduleMovie: (MovieData) -> Void
    
    var body: some View {
        List {
            if !movies.isEmpty {
                Section {
                    WatchlistQuickActionsView(
                        movies: movies,
                        onScheduleMovie: onScheduleMovie
                    )
                }
                .listRowBackground(Color.clear)
            }
            
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
            
            if !movies.isEmpty {
                Section("Statistics") {
                    WatchlistStatsView(movies: movies)
                }
            }
        }
    }
}

struct WatchlistQuickActionsView: View {
    let movies: [MovieData]
    let onScheduleMovie: (MovieData) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
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

struct WatchlistMovieRow: View {
    let movie: MovieData
    let movieService: MovieServiceProtocol
    let onSchedule: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
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
            
            VStack(spacing: 8) {
                Button(action: onSchedule) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.borderless)
                
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
            
            Button("Browse Movies") {
                navigationManager.navigateToMovies()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

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
