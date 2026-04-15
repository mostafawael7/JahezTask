import SwiftUI

struct CachedPosterView: View {
    let urls: [URL]
    let height: CGFloat
    let contentMode: ContentMode

    @State private var image: UIImage?
    @State private var isLoading = false

    private static let cache: URLCache = {
        URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 300 * 1024 * 1024,
            diskPath: "movie_posters_cache"
        )
    }()

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                    ProgressView()
                }
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task(id: urls.map(\.absoluteString).joined(separator: "|")) {
            await loadImage()
        }
    }

    init(url: URL?, height: CGFloat, contentMode: ContentMode = .fill) {
        self.urls = url.map { [$0] } ?? []
        self.height = height
        self.contentMode = contentMode
    }

    init(urls: [URL], height: CGFloat, contentMode: ContentMode = .fill) {
        self.urls = urls
        self.height = height
        self.contentMode = contentMode
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "film")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }

    @MainActor
    private func loadImage() async {
        guard !urls.isEmpty else { return }
        image = nil

        isLoading = true
        defer { isLoading = false }

        for url in urls {
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            request.timeoutInterval = 20

            if let cached = Self.cache.cachedResponse(for: request),
               let cachedImage = UIImage(data: cached.data) {
                image = cachedImage
                return
            }

            do {
                let (data, response) = try await Self.session.data(for: request)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    continue
                }
                if let downloaded = UIImage(data: data) {
                    image = downloaded
                    let cached = CachedURLResponse(response: response, data: data)
                    Self.cache.storeCachedResponse(cached, for: request)
                    return
                }
            } catch {
                continue
            }
        }
    }
}
