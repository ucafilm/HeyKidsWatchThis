// ContentView.swift - FINAL FIX
// HeyKidsWatchThis - Simplified with correct @Bindable wrapper for navigation

import SwiftUI

struct ContentView: View {
    @Environment(MovieService.self) private var movieService
    @Environment(NavigationManager.self) private var navigationManager

    var body: some View {
        // FIX: Create a bindable reference to the navigation manager.
        // This is the modern way to create a two-way binding to an
        // @Observable object from the environment.
        @Bindable var bindableNavigationManager = navigationManager

        // The TabView's selection now correctly binds to the shared NavigationManager state.
        TabView(selection: $bindableNavigationManager.selectedTab) {
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
            print("ContentView appeared")
            print("Movies available: \(movieService.getAllMovies().count)")
            print("Watchlist count: \(movieService.watchlist.count)")
        }
    }
}

// MARK: - Tab Views (No changes below this line)

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

// MARK: - Simple Movie List View (No changes)

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

// MARK: - Simple Movie Row (No changes)

// Helper struct for styling streaming service tags
private struct StreamingServiceStyle {
    let name: String
    let color: Color

    init(_ serviceName: String) {
        if serviceName.localizedStandardContains("Amazon") {
            self.name = "Amazon"
            self.color = .orange
        } else if serviceName.localizedStandardContains("Netflix") {
            self.name = "Netflix"
            self.color = .red
        } else if serviceName.localizedStandardContains("Disney") {
            self.name = "Disney+"
            self.color = .blue
        } else if serviceName.localizedStandardContains("Hulu") {
            self.name = "Hulu"
            self.color = .green
        } else if serviceName.localizedStandardContains("Max") {
            self.name = "Max"
            self.color = .purple
        } else {
            self.name = serviceName
            self.color = .secondary
        }
    }
}

struct SimpleMovieRow: View {
    let movie: MovieData
    let isInWatchlist: Bool
    let isWatched: Bool
    let onWatchlistToggle: () -> Void
    let onMarkWatched: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(movie.emoji)
                .font(.title)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(isWatched ? .secondary : .primary)
                
                Text("\(String(movie.year)) • \(movie.ageGroup.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(movie.genre)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(4)

                    ForEach(movie.streamingServices, id: \.self) { serviceName in
                        let style = StreamingServiceStyle(serviceName)
                        Text(style.name)
                            .font(.caption2).bold()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(style.color.opacity(0.15))
                            .foregroundColor(style.color)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: onWatchlistToggle) {
                    Image(systemName: isInWatchlist ? "heart.fill" : "heart")
                        .foregroundColor(isInWatchlist ? .red : .gray)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                Button(action: onMarkWatched) {
                    Image(systemName: isWatched ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isWatched ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .disabled(isWatched)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Helper Views (No changes)

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
