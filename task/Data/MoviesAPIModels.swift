import Foundation

struct DiscoverMoviesResponseDTO: Decodable {
    let page: Int
    let totalPages: Int
    let results: [MovieDTO]

    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case results
    }
}

struct GenresResponseDTO: Decodable {
    let genres: [GenreDTO]
}

struct GenreDTO: Decodable {
    let id: Int
    let name: String

    var toDomain: Genre {
        Genre(id: id, name: name)
    }
}

struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let releaseDate: String
    let posterPath: String?
    let genreIDs: [Int]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case genreIDs = "genre_ids"
    }

    var toDomain: Movie {
        Movie(id: id, title: title, releaseDateText: releaseDate, posterPath: posterPath, genreIDs: genreIDs)
    }
}

struct MovieDetailsDTO: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String
    let genres: [GenreDTO]
    let overview: String
    let homepage: String?
    let budget: Int
    let revenue: Int
    let spokenLanguages: [SpokenLanguageDTO]
    let status: String
    let runtime: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case genres
        case overview
        case homepage
        case budget
        case revenue
        case spokenLanguages = "spoken_languages"
        case status
        case runtime
    }

    var toDomain: MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            posterPath: posterPath,
            releaseDateText: releaseDate,
            genres: genres.map(\.name),
            overview: overview,
            homepage: homepage,
            budget: budget,
            revenue: revenue,
            spokenLanguages: spokenLanguages.map(\.displayName),
            status: status,
            runtime: runtime
        )
    }
}

struct SpokenLanguageDTO: Decodable {
    let englishName: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case name
    }

    var displayName: String {
        englishName.isEmpty ? name : englishName
    }
}
