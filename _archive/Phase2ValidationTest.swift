// Phase2ValidationTest.swift
// Quick compilation test for consolidated service layer

import SwiftUI
import Observation

// Test that we can create a MovieService and MovieListViewModel
struct Phase2ValidationTest: View {
    @State private var movieService: MovieService
    @State private var viewModel: MovieListViewModel
    
    init() {
        let dataProvider = MovieDataProvider()
        let service = MovieService(dataProvider: dataProvider)
        self.movieService = service
        self.viewModel = MovieListViewModel(movieService: service)
    }
    
    var body: some View {
        VStack {
            Text("Phase 2 Validation Test")
                .font(.title)
            
            Text("Movies: \(viewModel.movies.count)")
            Text("Watchlist: \(viewModel.watchlistCount)")
            Text("Filtered Movies: \(viewModel.filteredMovies.count)")
            
            if let stats = viewModel.getWatchlistStatistics() {
                Text("Stats Available: \(stats.totalCount) total")
            }
            
            Button("Test Watchlist") {
                if let firstMovie = viewModel.movies.first {
                    viewModel.toggleWatchlist(for: firstMovie)
                }
            }
        }
        .onAppear {
            viewModel.loadMovies()
        }
    }
}

// Test basic service functionality
func testServiceConsolidation() {
    let dataProvider = MovieDataProvider()
    let service = MovieService(dataProvider: dataProvider)
    
    print("✅ MovieService created successfully")
    print("📊 Movies: \(service.getAllMovies().count)")
    print("📝 Watchlist: \(service.watchlist.count)")
    
    let viewModel = MovieListViewModel(movieService: service)
    print("✅ MovieListViewModel created successfully")
    print("🎬 ViewModel movies: \(viewModel.movies.count)")
}
