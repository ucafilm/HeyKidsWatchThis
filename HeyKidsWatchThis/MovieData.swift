import Foundation

// Your existing MovieData struct...
struct MovieData: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let year: Int
    let ageGroup: AgeGroup
    let genre: String
    let emoji: String
    let streamingServices: [String]
    let rating: Double?
    let notes: String?
    
    // --- ✅ START OF FIX ---
    // Add state properties so each movie object can track its own status.
    // Use `var` to make them mutable. We'll set the default to false.
    var isInWatchlist: Bool = false
    var isWatched: Bool = false
    var scheduledDate: Date? = nil // NEW: Track when movie is scheduled
    // --- ✅ END OF FIX ---
    
    // Custom initializer to maintain compatibility with your Codable data
    // if it doesn't include the new properties.
    init(id: UUID = UUID(), title: String, year: Int, ageGroup: AgeGroup, genre: String, emoji: String, streamingServices: [String], rating: Double? = nil, notes: String? = nil, isInWatchlist: Bool = false, isWatched: Bool = false, scheduledDate: Date? = nil) {
        self.id = id
        self.title = title
        self.year = year
        self.ageGroup = ageGroup
        self.genre = genre
        self.emoji = emoji
        self.streamingServices = streamingServices
        self.rating = rating
        self.notes = notes
        self.isInWatchlist = isInWatchlist
        self.isWatched = isWatched
        self.scheduledDate = scheduledDate
    }
    
    // Convenience initializer without id parameter (generates UUID automatically)
    init(title: String, year: Int, ageGroup: AgeGroup, genre: String, emoji: String, streamingServices: [String], rating: Double? = nil, notes: String? = nil) {
        self.init(
            id: UUID(),
            title: title,
            year: year,
            ageGroup: ageGroup,
            genre: genre,
            emoji: emoji,
            streamingServices: streamingServices,
            rating: rating,
            notes: notes,
            isInWatchlist: false,
            isWatched: false,
            scheduledDate: nil
        )
    }
    
    // This makes sure JSON decoding works even if the saved data
    // doesn't have the new fields yet.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        year = try container.decode(Int.self, forKey: .year)
        ageGroup = try container.decode(AgeGroup.self, forKey: .ageGroup)
        genre = try container.decode(String.self, forKey: .genre)
        emoji = try container.decode(String.self, forKey: .emoji)
        streamingServices = try container.decode([String].self, forKey: .streamingServices)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // If the new keys don't exist in the JSON, they will keep their default value of `false`.
        isInWatchlist = (try? container.decodeIfPresent(Bool.self, forKey: .isInWatchlist)) ?? false
        isWatched = (try? container.decodeIfPresent(Bool.self, forKey: .isWatched)) ?? false
        scheduledDate = try? container.decodeIfPresent(Date.self, forKey: .scheduledDate)
    }
}
