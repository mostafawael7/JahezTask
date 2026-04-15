//
//  ContentView.swift
//  task
//
//  Created by Mostafa Hendawi on 15/04/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: HomeViewModel
    private let makeDetailsViewModel: (Int) -> MovieDetailsViewModel

    init() {
        let networkService = NetworkService()
        let repository = MoviesRepositoryImpl(networkService: networkService)
        let fetchGenresUseCase = FetchGenresUseCase(repository: repository)
        let fetchTrendingMoviesUseCase = FetchTrendingMoviesUseCase(repository: repository)
        let fetchMovieDetailsUseCase = FetchMovieDetailsUseCase(repository: repository)
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                fetchGenresUseCase: fetchGenresUseCase,
                fetchTrendingMoviesUseCase: fetchTrendingMoviesUseCase
            )
        )
        makeDetailsViewModel = { movieID in
            MovieDetailsViewModel(
                movieID: movieID,
                fetchMovieDetailsUseCase: fetchMovieDetailsUseCase
            )
        }
    }

    var body: some View {
        HomeView(
            viewModel: viewModel,
            makeDetailsViewModel: makeDetailsViewModel
        )
    }
}

#Preview {
    ContentView()
}
