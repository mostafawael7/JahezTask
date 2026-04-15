import Combine
import Foundation

protocol MoviesRepository {
    func fetchGenres() -> AnyPublisher<[Genre], NetworkError>
    func fetchTrendingMovies(page: Int, genreID: Int?, query: String) -> AnyPublisher<MoviesPage, NetworkError>
    func fetchMovieDetails(movieID: Int) -> AnyPublisher<MovieDetails, NetworkError>
}
