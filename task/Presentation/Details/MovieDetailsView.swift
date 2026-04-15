import SwiftUI

struct MovieDetailsView: View {
    @StateObject private var viewModel: MovieDetailsViewModel

    init(viewModel: MovieDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
//                ProgressView("Loading details...")
//                    .padding(.top, 40)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        viewModel.retry()
                    }
                }
                .padding(.top, 40)
            } else if let details = viewModel.details {
                VStack(alignment: .leading, spacing: 16) {
                    CachedPosterView(
                        urls: posterURLs(for: details.posterPath),
                        height: 520,
                        contentMode: .fill
                    )

                    Text(details.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    if hasText(details.releaseMonthYear) {
                        detailRow(title: "Release Date", value: details.releaseMonthYear)
                    }
                    if !details.genres.isEmpty {
                        detailRow(title: "Genres", value: details.genres.joined(separator: ", "))
                    }
                    if hasText(details.overview) {
                        detailRow(title: "Overview", value: details.overview)
                    }
                    if let homepage = cleaned(details.homepage) {
                        homepageRow(title: "Homepage", string: homepage)
                    }
                    if details.budget > 0 {
                        detailRow(title: "Budget", value: currency(details.budget))
                    }
                    if details.revenue > 0 {
                        detailRow(title: "Revenue", value: currency(details.revenue))
                    }
                    if !details.spokenLanguages.isEmpty {
                        detailRow(title: "Spoken Languages", value: details.spokenLanguages.joined(separator: ", "))
                    }
                    if hasText(details.status) {
                        detailRow(title: "Status", value: details.status)
                    }
                    if let runtime = details.runtime, runtime > 0 {
                        detailRow(title: "Runtime", value: "\(runtime) min")
                    }
                }
                .padding()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Movie Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            viewModel.loadIfNeeded()
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.yellow)
            Text(value)
                .font(.body)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func homepageRow(title: String, string: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.yellow)
            if let url = homepageURL(from: string) {
                Link(destination: url) {
                    Text(string)
                        .font(.body)
                        .foregroundStyle(.cyan)
                        .multilineTextAlignment(.leading)
                        .underline()
                }
            } else {
                Text(string)
                    .font(.body)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func homepageURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(trimmed)")
    }

    private func posterURLs(for path: String?) -> [URL] {
        guard let path, !path.isEmpty else { return [] }
        return [
            Constants.TMDB.originalImageBaseURL.appendingPathComponent(path),
            Constants.TMDB.largeImageBaseURL.appendingPathComponent(path),
            Constants.TMDB.imageBaseURL.appendingPathComponent(path)
        ]
    }

    private func cleaned(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func hasText(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func currency(_ value: Int) -> String {
        guard value > 0 else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
