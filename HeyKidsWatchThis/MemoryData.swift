import Foundation

struct MemoryData: Identifiable, Codable, Equatable {
    let id: UUID
    let movieId: UUID
    let watchDate: Date
    let rating: Int // 1-5 stars
    let notes: String?
    let discussionAnswers: [DiscussionAnswer]
    
    // NEW: Enhanced memory features
    let photos: [MemoryPhoto]
    let location: LocationContext?
    let weatherContext: WeatherContext?
    
    init(
        id: UUID = UUID(),
        movieId: UUID,
        watchDate: Date,
        rating: Int,
        notes: String? = nil,
        discussionAnswers: [DiscussionAnswer] = [],
        photos: [MemoryPhoto] = [],
        location: LocationContext? = nil,
        weatherContext: WeatherContext? = nil
    ) {
        self.id = id
        self.movieId = movieId
        self.watchDate = watchDate
        self.rating = rating
        self.notes = notes
        self.discussionAnswers = discussionAnswers
        self.photos = photos
        self.location = location
        self.weatherContext = weatherContext
    }
}

struct DiscussionAnswer: Identifiable, Codable, Equatable {
    let id: UUID
    let questionId: UUID
    let response: String
    let childAge: Int
    
    init(
        id: UUID = UUID(),
        questionId: UUID,
        response: String,
        childAge: Int
    ) {
        self.id = id
        self.questionId = questionId
        self.response = response
        self.childAge = childAge
    }
}
