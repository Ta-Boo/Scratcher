import Logger
import Foundation

// MARK: - API Client
public class APIClient {
    private let session: URLSession
    private let baseURL: URL

    public var isAuthorized: Bool {
        return true
    }

    public init(url: String) {
        let configuration = URLSessionConfiguration.default //can be injected if needed
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        self.baseURL = URL(string: url)! //crashing here is acceptable for invalid base URL
    }

    // MARK: - Generic Request Method



    public func request<T: Codable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try await buildRequest(for: endpoint)
        Logger.logRequest(endpoint.method.rawValue, url: endpoint.path, headers: endpoint.headers, body: endpoint.body)
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.logNetworkError(url: endpoint.path, error: APIError.invalidResponse)
                throw APIError.invalidResponse
            }
            if 200...299 ~= httpResponse.statusCode {
                Logger.logResponse(url: endpoint.path, status: httpResponse.statusCode, body: data)
            } else {
                Logger.log("HTTP error status=\(httpResponse.statusCode) url=\(endpoint.path)", level: .warning)
            }
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                Logger.logNetworkError(url: endpoint.path, error: APIError.decodingError(error))
                throw APIError.decodingError(error)
            }
        } catch {
            Logger.logNetworkError(url: endpoint.path, error: APIError.decodingError(error))
            throw error
        }
    }

    public func requestVoid(_ endpoint: APIEndpoint) async throws {
        let request = try await buildRequest(for: endpoint)
        Logger.logRequest(endpoint.method.rawValue, url: endpoint.path, headers: endpoint.headers, body: endpoint.body)
        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.logNetworkError(url: endpoint.path, error: APIError.invalidResponse)
                throw APIError.invalidResponse
            }
            if 200...299 ~= httpResponse.statusCode {
                Logger.logResponse(url: endpoint.path, status: httpResponse.statusCode)
            } else {
                Logger.log("HTTP error status=\(httpResponse.statusCode) url=\(endpoint.path)", level: .warning)
            }
            guard 200...299 ~= httpResponse.statusCode else { throw APIError.httpError(httpResponse.statusCode) }
        } catch {
            Logger.logNetworkError(url: endpoint.path, error: APIError.decodingError(error))
            throw error
        }
    }

    // MARK: - Public method for making requests without OAuth2 (for login, etc.)
    public func requestWithoutAuth<T: Codable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequestWithoutAuth(for: endpoint)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw parserAPIErrors(from: httpResponse)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    private func buildRequest(for endpoint: APIEndpoint) async throws -> URLRequest {
        var request = try buildRequestWithoutAuth(for: endpoint)
        //authorisation comes here if needed
        return request
    }

    private func buildRequestWithoutAuth(for endpoint: APIEndpoint) throws -> URLRequest {
        var request: URLRequest
        if endpoint.method == .GET, let parameters = endpoint.parameters, !parameters.isEmpty {
            var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
            components.queryItems = parameters.map { key, value in URLQueryItem(name: key, value: "\(value)") }
            components.percentEncodedQuery = components.percentEncodedQuery
            guard let finalURL = components.url else { throw APIError.invalidURL }
            request = URLRequest(url: finalURL)
        } else {
            request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        }
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if endpoint.method != .GET, let body = endpoint.body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        return request
    }

    private func parserAPIErrors(from response: HTTPURLResponse) -> APIError {
        return APIError.httpError(response.statusCode)
        //TODO: Parse specific error messages from response body if needed
    }
}

// MARK: - API Error
public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case unauthorized
    case networkError(Error)
    case other(String)
    case invalidDecoder

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized access"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .other(let message):
            return "Network error: \(message)"
        case .invalidDecoder:
            return "Invalid decoder"
        }
    }
}

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Endpoint Protocol
public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Codable? { get }
    var parameters: [String: Any]? { get }
}

