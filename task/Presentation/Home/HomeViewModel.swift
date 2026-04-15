import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var genres: [Genre] = []
    @Published private(set) var selectedGenreID: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasMore = true

    private let uiBatchSize = 10
    private var didLoadInitial = false
    private var pendingBuffer: [Movie] = []
    private var nextAPIPage = 1
    private var totalPages = Int.max

    private let fetchGenresUseCase: FetchGenresUseCase
    private let fetchTrendingMoviesUseCase: FetchTrendingMoviesUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchGenresUseCase: FetchGenresUseCase,
        fetchTrendingMoviesUseCase: FetchTrendingMoviesUseCase
    ) {
        self.fetchGenresUseCase = fetchGenresUseCase
        self.fetchTrendingMoviesUseCase = fetchTrendingMoviesUseCase
        bindSearch()
    }

    func loadIfNeeded() {
        guard !didLoadInitial else { return }
        didLoadInitial = true
        fetchGenres()
        fetchInitialMovies()
    }

    func fetchInitialMovies() {
        movies = []
        pendingBuffer = []
        nextAPIPage = 1
        totalPages = Int.max
        hasMore = true
        errorMessage = nil
        loadNextBatchIfNeeded(currentMovieID: nil)
    }

    func selectGenre(_ genreID: Int?) {
        guard selectedGenreID != genreID else { return }
        selectedGenreID = genreID
        fetchInitialMovies()
    }

    func loadNextBatchIfNeeded(currentMovieID: Int?) {
        if let currentMovieID {
            let threshold = max(0, movies.count - 3)
            guard let index = movies.firstIndex(where: { $0.id == currentMovieID }),
                  index >= threshold else {
                return
            }
        }

        guard !isLoading else { return }

        if pendingBuffer.count >= uiBatchSize {
            appendBatchFromBuffer()
            return
        }

        if nextAPIPage <= totalPages {
            fetchMoviesPage(page: nextAPIPage)
            return
        }

        hasMore = !pendingBuffer.isEmpty
        if !pendingBuffer.isEmpty {
            appendBatchFromBuffer()
        }
    }

    private func fetchMoviesPage(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        fetchTrendingMoviesUseCase.execute(page: page, genreID: selectedGenreID, query: searchQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] page in
                guard let self else { return }
                self.nextAPIPage = page.page + 1
                self.totalPages = page.totalPages
                let filteredByGenre = page.movies.filter { movie in
                    guard let selectedGenreID = self.selectedGenreID else { return true }
                    return movie.genreIDs.contains(selectedGenreID)
                }
                self.pendingBuffer.append(contentsOf: filteredByGenre)
                self.appendBatchFromBuffer()
            }
            .store(in: &cancellables)
    }

    private func fetchGenres() {
        fetchGenresUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] genres in
                self?.genres = genres.sorted(by: { $0.name < $1.name })
            }
            .store(in: &cancellables)
    }

    private func appendBatchFromBuffer() {
        guard !pendingBuffer.isEmpty else {
            hasMore = nextAPIPage <= totalPages
            return
        }

        let count = min(uiBatchSize, pendingBuffer.count)
        let newBatch = Array(pendingBuffer.prefix(count))
        pendingBuffer.removeFirst(count)
        movies.append(contentsOf: newBatch)
        hasMore = !pendingBuffer.isEmpty || nextAPIPage <= totalPages
    }

    private func bindSearch() {
        $searchQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, self.didLoadInitial else { return }
                self.fetchInitialMovies()
            }
            .store(in: &cancellables)
    }
}
