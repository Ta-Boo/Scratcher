import XCTest
@testable import APIClient

final class APIClientTests: XCTestCase {
    var sut: APIClient!

    override func setUp() {
        super.setUp()
        sut = APIClient(url: "https://api.o2.sk")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_withValidURL_shouldSucceed() {
        XCTAssertNotNil(sut)
    }

    // MARK: - Authorization Tests

    func testIsAuthorized_shouldReturnTrue() {
        XCTAssertTrue(sut.isAuthorized)
    }
}

final class ActivationEndpointTests: XCTestCase {

    // MARK: - Endpoint Configuration Tests

    func testActivationEndpoint_shouldHaveCorrectPath() {
        let endpoint = ActivationEndpoint(code: "TEST123")
        XCTAssertEqual(endpoint.path, "/version")
    }

    func testActivationEndpoint_shouldUseGetMethod() {
        let endpoint = ActivationEndpoint(code: "TEST123")
        XCTAssertEqual(endpoint.method, .GET)
    }

    func testActivationEndpoint_shouldHaveCodeParameter() {
        let code = "ABC123"
        let endpoint = ActivationEndpoint(code: code)

        guard let parameters = endpoint.parameters else {
            XCTFail("Parameters should not be nil")
            return
        }

        XCTAssertEqual(parameters["code"] as? String, code)
    }

    func testActivationEndpoint_withDifferentCodes_shouldHaveCorrectParameters() {
        let codes = ["TEST1", "XYZ789", "ABC123"]

        for code in codes {
            let endpoint = ActivationEndpoint(code: code)
            XCTAssertEqual(endpoint.parameters?["code"] as? String, code)
        }
    }
}

final class ActivationResponseTests: XCTestCase {

    // MARK: - Decoding Tests

    func testActivationResponse_shouldDecodeCorrectly() throws {
        let json = """
        {
            "ios": "6.24"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(ActivationResponse.self, from: json)

        XCTAssertEqual(response.ios, "6.24")
    }

    func testActivationResponse_withDifferentVersions_shouldDecodeCorrectly() throws {
        let versions = ["6.24", "6.1", "7.0", "5.9"]

        for version in versions {
            let json = """
            {
                "ios": "\(version)"
            }
            """.data(using: .utf8)!

            let decoder = JSONDecoder()
            let response = try decoder.decode(ActivationResponse.self, from: json)

            XCTAssertEqual(response.ios, version)
        }
    }

    func testActivationResponse_withInvalidJSON_shouldThrowError() {
        let invalidJSON = """
        {
            "android": "6.24"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(ActivationResponse.self, from: invalidJSON))
    }
}


final class HTTPMethodTests: XCTestCase {

    func testHTTPMethod_rawValues() {
        XCTAssertEqual(HTTPMethod.GET.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.POST.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.PUT.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.DELETE.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.PATCH.rawValue, "PATCH")
    }
}
