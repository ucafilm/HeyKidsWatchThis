// HeyKidsWatchThisApp.swift
// FIXED: Proper service initialization to prevent XPC connection issues
// Single source of truth for all services

import SwiftUI
import EventKit

@main
struct HeyKidsWatchThisApp: App {
    
    // FIXED: Create services ONCE and share them properly
    @State private var movieService: MovieService
    @State private var memoryService: MemoryService
    @State private var navigationManager: NavigationManager
    @State private var calendarService = CalendarService() // ADD SHARED CALENDAR SERVICE
    
    // FIXED: Proper initialization in init() to ensure single service instances
    init() {
        print("🚀 HeyKidsWatchThisApp initializing...")
        
        // Create data providers
        let movieDataProvider = MovieDataProvider()
        let memoryDataProvider = MemoryDataProvider()
        
        // Create services ONCE
        let movieService = MovieService(dataProvider: movieDataProvider)
        let memoryService = MemoryService(dataProvider: memoryDataProvider)
        
        // Create navigation manager with the SAME service instances
        let navigationManager = NavigationManager(
            movieService: movieService, 
            memoryService: memoryService
        )
        
        // Initialize @State properties
        self._movieService = State(initialValue: movieService)
        self._memoryService = State(initialValue: memoryService)
        self._navigationManager = State(initialValue: navigationManager)
        
        print("🚀 Services initialized successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(movieService)
                .environment(navigationManager)
                .environment(memoryService)
                .environmentObject(calendarService) // SHARE CALENDAR SERVICE
                .onAppear {
                    // Print debug information on app launch
                    print("🔍 DEBUG INFO ON LAUNCH:")
                    print("Movies: \(movieService.getAllMovies().count)")
                    print("Watchlist: \(movieService.watchlist.count)")
                    
                    // Request calendar permissions for scheduling
                    requestCalendarPermissions()
                }
        }
    }
    
    private func requestCalendarPermissions() {
        let eventStore = EKEventStore()
        
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        print("📅 Calendar access granted")
                    } else {
                        print("📅 Calendar access denied: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        print("📅 Calendar access granted")
                    } else {
                        print("📅 Calendar access denied: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
}
