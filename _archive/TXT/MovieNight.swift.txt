import Foundation

struct MovieNight: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let date: Date
    let movies: [MovieData]
    let ageGroup: AgeGroup
    let notes: String?
    let isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        movies: [MovieData],
        ageGroup: AgeGroup,
        notes: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.movies = movies
        self.ageGroup = ageGroup
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
