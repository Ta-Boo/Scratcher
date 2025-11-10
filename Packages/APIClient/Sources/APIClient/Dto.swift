import SwiftUI
import Logger

extension APIEndpoint {
    public var headers: [String: String] {
        return [:]
    }

    public var body: Codable? {
        return nil
    }

    public var parameters: [String: Any]? {
        return nil
    }
}

// MARK: - Activation Endpoint
public struct ActivationEndpoint: APIEndpoint {
    public let path: String = "/version"
    public let method: HTTPMethod = .GET
    public let code: String

    public var parameters: [String: Any]? {
        return ["code": code]
    }

    public init(code: String) {
        self.code = code
    }
}

// MARK: - Activation Response
public struct ActivationResponse: Codable {
    public let ios: String

    public init(ios: String) {
        self.ios = ios
    }
}
