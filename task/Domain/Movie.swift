import Foundation

struct Movie: Identifiable, Equatable {
    let id: Int
    let title: String
    let releaseDateText: String
    let posterPath: String?
    let genreIDs: [Int]

    var releaseYear: String {
        String(releaseDateText.prefix(4))
    }
}

struct Genre: Identifiable, Equatable {
    let id: Int
    let name: String
}
