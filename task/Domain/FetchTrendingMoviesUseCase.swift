import Combine
import Foundation

struct FetchTrendingMoviesUseCase {
    private let repository: MoviesRepository

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    func execute(page: Int, genreID: Int?, query: String) -> AnyPublisher<MoviesPage, NetworkError> {
        repository.fetchTrendingMovies(page: page, genreID: genreID, query: query)
    }
}

struct FetchGenresUseCase {
    private let repository: MoviesRepository

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[Genre], NetworkError> {
        repository.fetchGenres()
    }
}
