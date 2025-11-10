import Foundation

public enum LogLevel: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"

    var header: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

public class Logger {
    private static let encoder = JSONEncoder()

    public static func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #file,
        line: Int = #line
    ) {
        let filename = (file as NSString).lastPathComponent
        let logMessage = "[\(level.header) \(level.rawValue)] \(filename):\(line) \(message)"
        debugPrint(logMessage)
    }
    public static func logRequest(
        _ method: String,
        url: String,
        headers: [String: String],
        body: Codable? = nil,
        file: String = #file,
        line: Int = #line
    ) {
        let headerSnippet = headers.map { "\($0): \($1)" }.joined(separator: ", ")
        var bodyText = ""
        if let body = body,
           let data = try? encoder.encode(body),
           let json = String(data: data, encoding: .utf8) {
            bodyText = json
        }
        log("""
        REQUEST:
        Method: \(method)
        URL: \(url)
        Headers: [\(headerSnippet)]
        Body: \(bodyText)
        """)
    }

    public static func logResponse(
        url: String,
        status: Int,
        body: Data? = nil,
        file: String = #file,
        line: Int = #line
    ) {
        let body = String(decoding: body ?? Data(), as: UTF8.self)
        log("RESPONSE (url: \(url))\nStatus: \(status)\nData: \(body)", file: file, line: line)
    }

    public static func logNetworkError(
        url: String,
        error: Error,
        file: String = #file,
        line: Int = #line
    ) {
        log("NETWORK ERROR (url: \(url))\nError: \(error.localizedDescription)", level: .error, file: file, line: line)
    }
}


