import Combine
import Foundation

struct FetchMovieDetailsUseCase {
    private let repository: MoviesRepository

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    func execute(movieID: Int) -> AnyPublisher<MovieDetails, NetworkError> {
        repository.fetchMovieDetails(movieID: movieID)
    }
}
