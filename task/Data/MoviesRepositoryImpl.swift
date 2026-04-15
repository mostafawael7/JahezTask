import Combine
import Foundation

final class MoviesRepositoryImpl: MoviesRepository {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func fetchGenres() -> AnyPublisher<[Genre], NetworkError> {
        var components = URLComponents(
            url: Constants.TMDB.baseURL.appendingPathComponent("genre/movie/list"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.TMDB.apiKey)
        ]

        guard let url = components?.url else {
            return Fail(error: NetworkError.unknown("Invalid genres URL."))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(Constants.TMDB.readAccessToken)", forHTTPHeaderField: "Authorization")

        return networkService.request(request)
            .map { (response: GenresResponseDTO) in
                response.genres.map(\.toDomain)
            }
            .eraseToAnyPublisher()
    }

    func fetchTrendingMovies(page: Int, genreID: Int?, query: String) -> AnyPublisher<MoviesPage, NetworkError> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let endpoint = trimmedQuery.isEmpty ? "discover/movie" : "search/movie"
        var components = URLComponents(
            url: Constants.TMDB.baseURL.appendingPathComponent(endpoint),
            resolvingAgainstBaseURL: false
        )
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "api_key", value: Constants.TMDB.apiKey)
        ]
        if trimmedQuery.isEmpty {
            queryItems.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
        } else {
            queryItems.append(URLQueryItem(name: "query", value: trimmedQuery))
        }
        if let genreID {
            queryItems.append(URLQueryItem(name: "with_genres", value: String(genreID)))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            return Fail(error: NetworkError.unknown("Invalid request URL."))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(Constants.TMDB.readAccessToken)", forHTTPHeaderField: "Authorization")

        return networkService.request(request)
            .map { (response: DiscoverMoviesResponseDTO) in
                MoviesPage(
                    page: response.page,
                    totalPages: response.totalPages,
                    movies: response.results.map(\.toDomain)
                )
            }
            .eraseToAnyPublisher()
    }

    func fetchMovieDetails(movieID: Int) -> AnyPublisher<MovieDetails, NetworkError> {
        var components = URLComponents(
            url: Constants.TMDB.baseURL.appendingPathComponent("movie/\(movieID)"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.TMDB.apiKey)
        ]

        guard let url = components?.url else {
            return Fail(error: NetworkError.unknown("Invalid movie details URL."))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(Constants.TMDB.readAccessToken)", forHTTPHeaderField: "Authorization")

        return networkService.request(request)
            .map { (response: MovieDetailsDTO) in
                response.toDomain
            }
            .eraseToAnyPublisher()
    }
}
