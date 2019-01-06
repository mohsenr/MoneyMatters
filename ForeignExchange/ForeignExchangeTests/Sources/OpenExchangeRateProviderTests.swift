import XCTest
@testable import ForeignExchange

class OpenExchangeRateProviderTests: XCTestCase {
    
    func testRateURL() {
        let key = UUID().uuidString
        let provider = OpenExchangeRateProvider(keyValue: key)
        
        let expected = URLComponents(url: provider.ratesURL, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(expected.scheme, "https")
        XCTAssertEqual(expected.host, "openexchangerates.org")
        XCTAssertEqual(expected.path, "/api/latest.json")
        XCTAssertEqual(expected.queryItems?["app_id"], key)
        guard let symbolsQuery = expected.queryItems?["symbols"] else {
            XCTFail("Missing `symbols`")
            return
        }
        let providedCurrencies = symbolsQuery.split(separator: ",").map { String($0) }
        let expectedCodes = provider.supportedCurrencies.map { $0.code }
        XCTAssertTrue(providedCurrencies.elementsEqual(expectedCodes))
    }
    
}

private extension Collection where Element == URLQueryItem {
    
    subscript (_ name: String) -> String? {
        get {
            return first { $0.name == name }?.value
        }
    }
    
}
