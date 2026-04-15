import Combine
import Foundation

@MainActor
final class MovieDetailsViewModel: ObservableObject {
    @Published private(set) var details: MovieDetails?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let movieID: Int
    private let fetchMovieDetailsUseCase: FetchMovieDetailsUseCase
    private var cancellables = Set<AnyCancellable>()
    private var didLoad = false

    init(movieID: Int, fetchMovieDetailsUseCase: FetchMovieDetailsUseCase) {
        self.movieID = movieID
        self.fetchMovieDetailsUseCase = fetchMovieDetailsUseCase
    }

    func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        fetchDetails()
    }

    func retry() {
        fetchDetails()
    }

    private func fetchDetails() {
        isLoading = true
        errorMessage = nil

        fetchMovieDetailsUseCase.execute(movieID: movieID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] details in
                self?.details = details
            }
            .store(in: &cancellables)
    }
}
