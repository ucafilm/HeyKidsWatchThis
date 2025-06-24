// ContentView.swift - MINIMAL WORKING VERSION
// HeyKidsWatchThis - Simplified to prevent black screen issues

import SwiftUI

struct ContentView: View {
    @Environment(MovieService.self) private var movieService
    @Environment(NavigationManager.self) private var navigationManager
    @State private var selectedTab: AppTab = .movies
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Movies Tab
            MoviesTabView()
                .tabItem {
                    Label("Movies", systemImage: "popcorn")
                }
                .tag(AppTab.movies)
            
            // Watchlist Tab
            WatchlistTabView()
                .tabItem {
                    Label("Watchlist", systemImage: "heart")
                }
                .tag(AppTab.watchlist)
            
            // Memories Tab
            MemoriesTabView()
                .tabItem {
                    Label("Memories", systemImage: "photo.on.rectangle")
                }
                .tag(AppTab.memories)
            
            // Settings Tab
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppTab.settings)
        }
        .onAppear {
            print("🎬 ContentView appeared")
            print("🎬 Movies available: \(movieService.getAllMovies().count)")
            print("🎬 Watchlist count: \(movieService.watchlist.count)")
        }
    }
}

// MARK: - Tab Views

struct MoviesTabView: View {
    @Environment(MovieService.self) private var movieService
    @State private var movieListViewModel: MovieListViewModel?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let viewModel = movieListViewModel {
                    SimpleMovieListView(viewModel: viewModel)
                } else {
                    ProgressView("Loading movies...")
                        .onAppear {
                            movieListViewModel = MovieListViewModel(movieService: movieService)
                        }
                }
            }
            .navigationTitle("Movies")
        }
    }
}

struct WatchlistTabView: View {
    var body: some View {
        NavigationStack {
            WatchlistView()
                .navigationTitle("Watchlist")
        }
    }
}

struct MemoriesTabView: View {
    var body: some View {
        NavigationStack {
            MemoryView()
                .navigationTitle("Memories")
        }
    }
}

struct SettingsTabView: View {
    var body: some View {
        NavigationStack {
            SettingsView()
                .navigationTitle("Settings")
        }
    }
}

// MARK: - Simple Movie List View

struct SimpleMovieListView: View {
    @Bindable var viewModel: MovieListViewModel
    
    var body: some View {
        VStack {
            // Search bar
            SearchBar(text: $viewModel.searchText)
                .padding(.horizontal)
            
            // Movie list
            if viewModel.isLoading {
                ProgressView("Loading movies...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredMovies.isEmpty {
                EmptyMovieListView()
            } else {
                List(viewModel.filteredMovies) { movie in
                    SimpleMovieRow(
                        movie: movie,
                        isInWatchlist: viewModel.isInWatchlist(movie),
                        isWatched: viewModel.isWatched(movie),
                        onWatchlistToggle: {
                            viewModel.toggleWatchlist(for: movie)
                        },
                        onMarkWatched: {
                            viewModel.markAsWatched(movie)
                        }
                    )
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            viewModel.loadMovies()
        }
    }
}

// MARK: - Simple Movie Row

struct SimpleMovieRow: View {
    let movie: MovieData
    let isInWatchlist: Bool
    let isWatched: Bool
    let onWatchlistToggle: () -> Void
    let onMarkWatched: () -> Void
    
    var body: some View {
        HStack {
            // Movie emoji
            Text(movie.emoji)
                .font(.title2)
            
            // Movie details
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(isWatched ? .secondary : .primary)
                
                Text("\(movie.year) • \(movie.ageGroup.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(movie.genre)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 8) {
                Button(action: onWatchlistToggle) {
                    Image(systemName: isInWatchlist ? "heart.fill" : "heart")
                        .foregroundColor(isInWatchlist ? .red : .gray)
                }
                .buttonStyle(.plain)
                
                Button(action: onMarkWatched) {
                    Image(systemName: isWatched ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isWatched ? .green : .gray)
                }
                .buttonStyle(.plain)
                .disabled(isWatched)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helper Views

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search movies...", text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct EmptyMovieListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "popcorn")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Movies Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search or check back later.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(MovieService(dataProvider: MovieDataProvider()))
        .environment(NavigationManager())
        .environment(MemoryService(dataProvider: MemoryDataProvider()))
}
