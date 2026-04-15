import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    private let makeDetailsViewModel: (Int) -> MovieDetailsViewModel
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    init(viewModel: HomeViewModel, makeDetailsViewModel: @escaping (Int) -> MovieDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeDetailsViewModel = makeDetailsViewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Trending Movies")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                TextField(
                    "",
                    text: $viewModel.searchQuery,
                    prompt: Text("Search movies").foregroundColor(.white.opacity(0.85))
                )
                    .padding(12)
                    .background(Color.white.opacity(0.12))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            viewModel.selectGenre(nil)
                        } label: {
                            Text("All")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(viewModel.selectedGenreID == nil ? .black : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedGenreID == nil ? Color.yellow : Color.black)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.yellow, lineWidth: 1.2)
                                )
                        }
                        .buttonStyle(.plain)

                        ForEach(viewModel.genres) { genre in
                            Button {
                                viewModel.selectGenre(genre.id)
                            } label: {
                                Text(genre.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(viewModel.selectedGenreID == genre.id ? .black : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(viewModel.selectedGenreID == genre.id ? Color.yellow : Color.black)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.yellow, lineWidth: 1.2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }

                // Only take over the whole area while loading the *first* page.
                // Pagination sets `isLoading` too; keeping the grid mounted preserves scroll position.
                if let error = viewModel.errorMessage, viewModel.movies.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text(error)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            viewModel.fetchInitialMovies()
                        }
                    }
                    Spacer()
                } else if viewModel.isLoading && viewModel.movies.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView("Loading movies...")
                        Spacer()
                    }
                    Spacer()
                } else if viewModel.movies.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                        Text("No results found")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(emptyStateMessage)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink {
                                    MovieDetailsView(
                                        viewModel: makeDetailsViewModel(movie.id)
                                    )
                                } label: {
                                    VStack(alignment: .leading, spacing: 10) {
                                        CachedPosterView(
                                            url: posterURL(for: movie.posterPath),
                                            height: 170
                                        )

                                        Text(movie.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(2)

                                        Text(movie.releaseYear)
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)

                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    }
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    viewModel.loadNextBatchIfNeeded(currentMovieID: movie.id)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .overlay(alignment: .bottom) {
                        if viewModel.isLoading && !viewModel.movies.isEmpty {
                            ProgressView()
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding(.top, 8)
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadIfNeeded()
            }
        }
    }

    private func posterURL(for path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return Constants.TMDB.imageBaseURL.appendingPathComponent(path)
    }

    private var emptyStateMessage: String {
        let query = viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return "No movies match the selected filters."
        }
        return "No movies found for \"\(query)\"."
    }

}


#Preview {
    let repository = MoviesRepositoryImpl(networkService: NetworkService())
    HomeView(
        viewModel: HomeViewModel(
            fetchGenresUseCase: FetchGenresUseCase(repository: repository),
            fetchTrendingMoviesUseCase: FetchTrendingMoviesUseCase(repository: repository)
        ),
        makeDetailsViewModel: { movieID in
            MovieDetailsViewModel(
                movieID: movieID,
                fetchMovieDetailsUseCase: FetchMovieDetailsUseCase(repository: repository)
            )
        }
    )
}
