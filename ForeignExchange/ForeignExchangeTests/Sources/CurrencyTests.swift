import XCTest
@testable import ForeignExchange

class CurrencyTests: XCTestCase {
    
    func testThatCurrencyCodeCaseIsConvertedToUpperCase() {
        XCTAssertEqual(Currency(code: "abc").code, "ABC")
    }
    
    func testThatCurrencyCodeCaseDoesNotAffectEquality() {
        XCTAssertEqual(Currency(code: "abc"), Currency(code: "ABC"))
    }
    
}
