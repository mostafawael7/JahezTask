import Foundation

enum Constants {
    enum TMDB {
        static let apiKey = "0648c2a668bdb36be62962d90c8ca900"
        static let readAccessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwNjQ4YzJhNjY4YmRiMzZiZTYyOTYyZDkwYzhjYTkwMCIsIm5iZiI6MTc1MDE1Njk3OC44NjgsInN1YiI6IjY4NTE0NmIyNzliYTQ2ZjM2M2I2ZGYzNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.sDp6NDjWwoPrF7r6I2hAJuxOHb3xPQ4gNXL2dkM_U4E"
        static let baseURL = URL(string: "https://api.themoviedb.org/3")!
        static let imageBaseURL = URL(string: "https://image.tmdb.org/t/p/w500")!
        static let largeImageBaseURL = URL(string: "https://image.tmdb.org/t/p/w780")!
        static let originalImageBaseURL = URL(string: "https://image.tmdb.org/t/p/original")!
    }
}
