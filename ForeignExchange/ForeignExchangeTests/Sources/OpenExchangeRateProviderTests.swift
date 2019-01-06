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
    
    func testParsingValidResponse() throws {
        let response =
            """
            {
            "disclaimer": "Usage subject to terms: https://openexchangerates.org/terms",
            "license": "https://openexchangerates.org/license",
            "timestamp": 1546783204,
            "base": "USD",
            "rates": {
                "CHF": 0.986485,
                "EUR": 0.877535,
                "GBP": 0.785545,
                "USD": 1
            }
            }
            """.data(using: .utf8)!
        
        let key = UUID().uuidString
        let provider = OpenExchangeRateProvider(keyValue: key)
        let rates = try provider.parseRateResponse(response)
        XCTAssertEqual(rates, [
            Currency(code: "CHF"): 0.986485,
            Currency(code: "EUR"): 0.877535,
            Currency(code: "GBP"): 0.785545,
            Currency(code: "USD"): 1,
            ])
    }
    
    func testParsingInvalidResponse() {
        let response =
            """
            Not json
            """.data(using: .utf8)!
        
        let key = UUID().uuidString
        let provider = OpenExchangeRateProvider(keyValue: key)
        XCTAssertThrowsError(try provider.parseRateResponse(response))
    }
    
}

private extension Collection where Element == URLQueryItem {
    
    subscript (_ name: String) -> String? {
        get {
            return first { $0.name == name }?.value
        }
    }
    
}
