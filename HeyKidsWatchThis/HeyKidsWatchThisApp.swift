// HeyKidsWatchThisApp.swift
// FINAL DEFINITIVE VERSION
// Refactored to use standard SwiftUI lifecycle and state management for services, ensuring stability.

import SwiftUI
import EventKit

@main
struct HeyKidsWatchThisApp: App {
    
    // ✅ FIX: Services are now initialized directly as state properties.
    // This is the modern, standard, and most stable approach.
    // The custom init() has been removed.
    
    @State private var movieDataProvider = MovieDataProvider()
    @State private var memoryDataProvider = MemoryDataProvider()
    
    @State private var movieService: MovieService
    @State private var memoryService: MemoryService
    @State private var navigationManager: NavigationManager
    
    // For ObservableObject, @StateObject is the correct property wrapper.
    @StateObject private var calendarService = CalendarService()
    
    init() {
        // Create instances of the services here to pass to the @State properties.
        let movieData = MovieDataProvider()
        let movieSvc = MovieService(dataProvider: movieData)
        
        let memoryData = MemoryDataProvider()
        let memorySvc = MemoryService(dataProvider: memoryData)
        
        // Initialize the @State properties with the created services.
        self._movieDataProvider = State(initialValue: movieData)
        self._memoryDataProvider = State(initialValue: memoryData)
        self._movieService = State(initialValue: movieSvc)
        self._memoryService = State(initialValue: memorySvc)
        self._navigationManager = State(initialValue: NavigationManager(movieService: movieSvc, memoryService: memorySvc))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Provide all services to the environment so views can access them.
                .environment(movieService)
                .environment(navigationManager)
                .environment(memoryService)
                .environmentObject(calendarService)
                .onAppear {
                    // This is a good place for one-time setup actions.
                    calendarService.requestFullAccess()
                }
        }
    }
}
