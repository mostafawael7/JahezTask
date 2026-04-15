import Combine
import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed
    case noInternet
    case timeout
    case cancelled
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case .requestFailed(let statusCode, let message):
            if let message, !message.isEmpty {
                return "Request failed (\(statusCode)): \(message)"
            }
            return "Request failed with status code \(statusCode)."
        case .decodingFailed:
            return "Failed to parse server response."
        case .noInternet:
            return "No internet connection."
        case .timeout:
            return "Request timed out."
        case .cancelled:
            return "Request was cancelled."
        case .unknown(let message):
            return message
        }
    }
}

final class NetworkService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// Generic request function for all API calls.
    func request<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, NetworkError> {
        let start = Date()
        let method = urlRequest.httpMethod ?? "GET"
        let urlString = urlRequest.url?.absoluteString ?? "unknown-url"
        print("🌐 [Request] \(method) \(urlString)")
        if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
            print("📨 [RequestHeaders] \(headers)")
        }
        if let body = urlRequest.httpBody, !body.isEmpty {
            print("📦 [RequestBody] \(Self.prettyPrintedJSONOrString(from: body))")
        }

        return session.dataTaskPublisher(for: urlRequest)
            .mapError(Self.mapURLError(_:))
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse else {
                    print("❌ [Response] \(method) \(urlString) invalid response")
                    throw NetworkError.invalidResponse
                }

                guard (200...299).contains(response.statusCode) else {
                    let message = Self.extractServerMessage(from: output.data)
                    let elapsed = String(format: "%.3f", Date().timeIntervalSince(start))
                    print("❌ [Response] \(method) \(urlString) status=\(response.statusCode) time=\(elapsed)s message=\(message ?? "n/a")")
                    throw NetworkError.requestFailed(statusCode: response.statusCode, message: message)
                }

                let elapsed = String(format: "%.3f", Date().timeIntervalSince(start))
                print("✅ [Response] \(method) \(urlString) status=\(response.statusCode) bytes=\(output.data.count) time=\(elapsed)s")
                print("📥 [ResponseBody] \(Self.prettyPrintedJSONOrString(from: output.data, maxLength: 2000))")
                return output.data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let networkError = error as? NetworkError {
                    print("❌ [NetworkError] \(method) \(urlString) \(networkError.localizedDescription)")
                    return networkError
                }
                if error is DecodingError {
                    print("❌ [DecodingError] \(method) \(urlString) \(error.localizedDescription)")
                    return .decodingFailed
                }
                print("❌ [UnknownError] \(method) \(urlString) \(error.localizedDescription)")
                return .unknown(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    nonisolated private static func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet:
            return .noInternet
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        default:
            return .unknown(error.localizedDescription)
        }
    }

    nonisolated private static func extractServerMessage(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }

        return object["status_message"] as? String
            ?? object["message"] as? String
            ?? object["error"] as? String
    }

    nonisolated private static func prettyPrintedJSONOrString(from data: Data, maxLength: Int = 1000) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let string = String(data: prettyData, encoding: .utf8) {
            return truncated(string, maxLength: maxLength)
        }

        if let string = String(data: data, encoding: .utf8) {
            return truncated(string, maxLength: maxLength)
        }

        return "<binary \(data.count) bytes>"
    }

    nonisolated private static func truncated(_ string: String, maxLength: Int) -> String {
        guard string.count > maxLength else { return string }
        let endIndex = string.index(string.startIndex, offsetBy: maxLength)
        return String(string[..<endIndex]) + "... [truncated]"
    }
}
