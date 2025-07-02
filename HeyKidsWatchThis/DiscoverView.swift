// DiscoverView.swift
// Enhanced DiscoverView with iOS 17+ Features - TDD GREEN PHASE Implementation
// Following Context7-verified patterns and modern SwiftUI best practices

import SwiftUI
import os.log

// MARK: - Enhanced DiscoverView Implementation

struct DiscoverView: View {
    @Bindable var movieService: MovieService
    @State private var searchText = ""
    @State private var selectedAgeGroup: AgeGroup?
    @State private var showingFilters = false
    @State private var animationTrigger = false
    
    private let logger = Logger(subsystem: "com.heykidswatchthis.app", category: "DiscoverView")
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Header
                searchAndFilterHeader
                
                // Movie Grid Content
                movieGridContent
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .searchable(text: $searchText, prompt: "Search movies...")
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .task {
                await loadMoviesWithAnimation()
            }
            .sensoryFeedback(.impact(.light), trigger: selectedAgeGroup)
        }
    }
    
    // MARK: - View Components
    
    private var searchAndFilterHeader: some View {
        VStack(spacing: 12) {
            // Age Group Filter Pills
            if !AgeGroup.allCases.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                            AgeGroupFilterPill(
                                ageGroup: ageGroup,
                                isSelected: selectedAgeGroup == ageGroup
                            ) {
                                handleAgeGroupSelection(ageGroup)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 44)
            }
            
            // Active Filters Display
            if selectedAgeGroup != nil || !searchText.isEmpty {
                activeFiltersView
            }
        }
        .padding(.vertical, 8)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var activeFiltersView: some View {
        HStack {
            Text("Active Filters:")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let selectedAgeGroup = selectedAgeGroup {
                FilterChip(text: selectedAgeGroup.description) {
                    self.selectedAgeGroup = nil
                }
            }
            
            if !searchText.isEmpty {
                FilterChip(text: "Search: \(searchText)") {
                    searchText = ""
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var movieGridContent: some View {
        Group {
            if filteredMovies.isEmpty {
                emptyStateView
            } else {
                movieGrid
            }
        }
        .animation(.smooth(duration: 0.6), value: filteredMovies.count)
    }
    
    private var movieGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(Array(filteredMovies.enumerated()), id: \.element.id) { index, movie in
                    EnhancedMovieCard(
                        movie: movie,
                        isInWatchlist: movieService.isInWatchlist(movie.id),
                        onWatchlistToggle: {
                            handleWatchlistToggle(for: movie)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .animation(.bouncy(duration: 0.8).delay(Double(index) * 0.05), value: animationTrigger)
                }
            }
            .padding()
        }
        .refreshable {
            await refreshMovies()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "popcorn")
                .font(.system(size: 64))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.bounce.up.byLayer, options: .repeating)
            
            VStack(spacing: 8) {
                Text("No Movies Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Clear Filters") {
                clearAllFilters()
            }
            .buttonStyle(.borderedProminent)
            .opacity((selectedAgeGroup != nil || !searchText.isEmpty) ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale))
    }
    
    private var filterButton: some View {
        Button(action: { showingFilters.toggle() }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolEffect(.bounce, value: showingFilters)
        }
        .popover(isPresented: $showingFilters) {
            FilterOptionsView(
                selectedAgeGroup: $selectedAgeGroup,
                searchText: $searchText
            )
            .presentationCompactAdaptation(.popover)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredMovies: [MovieData] {
        movieService.getAllMovies()
            .filter { movie in
                // Age group filter
                if let selectedAgeGroup = selectedAgeGroup {
                    guard movie.ageGroup == selectedAgeGroup else { return false }
                }
                
                // Search filter
                if !searchText.isEmpty {
                    return movie.title.localizedStandardContains(searchText) ||
                           movie.genre.localizedStandardContains(searchText) ||
                           movie.streamingServices.contains { $0.localizedStandardContains(searchText) }
                }
                
                return true
            }
            .sorted { $0.title < $1.title }
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
        ]
    }
    
    private var emptyStateMessage: String {
        if selectedAgeGroup != nil && !searchText.isEmpty {
            return "Try adjusting your age group or search terms"
        } else if selectedAgeGroup != nil {
            return "No movies found for \(selectedAgeGroup!.description)"
        } else if !searchText.isEmpty {
            return "No movies match your search for \"\(searchText)\""
        } else {
            return "Check back later for new movie recommendations"
        }
    }
    
    // MARK: - Actions
    
    private func handleAgeGroupSelection(_ ageGroup: AgeGroup) {
        withAnimation(.snappy(duration: 0.4)) {
            selectedAgeGroup = selectedAgeGroup == ageGroup ? nil : ageGroup
        }
        
        logger.info("Age group filter changed to: \(ageGroup.rawValue)")
    }
    
    private func handleWatchlistToggle(for movie: MovieData) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if movieService.isInWatchlist(movie.id) {
                movieService.removeFromWatchlist(movie.id)
            } else {
                movieService.addToWatchlist(movie.id)
            }
        }
    }
    
    private func clearAllFilters() {
        withAnimation(.smooth(duration: 0.5)) {
            selectedAgeGroup = nil
            searchText = ""
        }
    }
    
    @MainActor
    private func loadMoviesWithAnimation() async {
        withAnimation(.smooth(duration: 0.8)) {
            animationTrigger.toggle()
        }
    }
    
    @MainActor
    private func refreshMovies() async {
        // Implement refresh logic
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network call
        withAnimation(.bouncy) {
            animationTrigger.toggle()
        }
    }
}

// MARK: - Supporting Views

struct AgeGroupFilterPill: View {
    let ageGroup: AgeGroup
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(ageGroup.emoji)
                    .font(.caption)
                
                Text(ageGroup.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.accentColor : Color.secondary.opacity(0.1),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption2)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.secondary.opacity(0.2), in: Capsule())
        .foregroundStyle(.secondary)
    }
}

struct EnhancedMovieCard: View {
    let movie: MovieData
    let isInWatchlist: Bool
    let onWatchlistToggle: () -> Void
    
    @State private var isPressed = false
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Movie Poster Area
            moviePosterView
            
            // Movie Information
            movieInfoView
            
            // Action Buttons
            actionButtonsView
        }
        .padding(12)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.snappy(duration: 0.2), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                showingDetails = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
        .sensoryFeedback(.impact(.medium), trigger: isPressed)
        .sheet(isPresented: $showingDetails) {
            MovieDetailView(movie: movie)
        }
    }
    
    private var moviePosterView: some View {
        ZStack {
            // Placeholder background
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .aspectRatio(2/3, contentMode: .fit)
                .overlay {
                    VStack {
                        Text(movie.emoji)
                            .font(.system(size: 40))
                        
                        Text(movie.ageGroup.emoji)
                            .font(.caption)
                            .padding(4)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            
            // Watchlist indicator
            if isInWatchlist {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(6)
                            .background(.ultraThinMaterial, in: Circle())
                            .symbolEffect(.bounce, value: isInWatchlist)
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
    }
    
    private var movieInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text("\(movie.year) • \(movie.genre)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let rating = movie.rating {
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(rating) ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        HStack {
            Button(action: onWatchlistToggle) {
                Label(
                    isInWatchlist ? "Remove" : "Add to Watchlist",
                    systemImage: isInWatchlist ? "heart.fill" : "heart"
                )
                .font(.caption)
                .labelStyle(.iconOnly)
                .symbolEffect(.bounce, value: isInWatchlist)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.mini)
            
            Spacer()
            
            Text(movie.ageGroup.ageRange)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.secondary.opacity(0.1), in: Capsule())
                .foregroundStyle(.secondary)
        }
    }
}

struct FilterOptionsView: View {
    @Binding var selectedAgeGroup: AgeGroup?
    @Binding var searchText: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Age Groups") {
                    ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                        HStack {
                            Text(ageGroup.description)
                            Spacer()
                            if selectedAgeGroup == ageGroup {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .symbolEffect(.bounce, value: selectedAgeGroup)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedAgeGroup = selectedAgeGroup == ageGroup ? nil : ageGroup
                        }
                    }
                }
                
                Section("Actions") {
                    Button("Clear All Filters") {
                        selectedAgeGroup = nil
                        searchText = ""
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

struct MovieDetailView: View {
    let movie: MovieData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Movie header
                    HStack {
                        Text(movie.emoji)
                            .font(.system(size: 60))
                        
                        VStack(alignment: .leading) {
                            Text(movie.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(movie.year) • \(movie.genre)")
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    // Movie details
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(title: "Age Group", value: movie.ageGroup.description)
                        DetailRow(title: "Streaming", value: movie.streamingServices.joined(separator: ", "))
                        if let rating = movie.rating {
                            DetailRow(title: "Rating", value: String(format: "%.1f/5.0", rating))
                        }
                        if let notes = movie.notes {
                            DetailRow(title: "Notes", value: notes)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Movie Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    DiscoverView(movieService: MovieService(dataProvider: MovieDataProvider()))
        .environment(NavigationManager())
}
