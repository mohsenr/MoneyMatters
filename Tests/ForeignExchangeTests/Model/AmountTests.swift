import XCTest
@testable import ForeignExchange

class AmountTests: XCTestCase {
    
    func testThatGBPAmountsKeepsTwoFractionDigits() {
        let actual = Amount(value: 1.234, in: .gbp).value
        let expected = Decimal(value: 1.234, significantFractionDigits: 2)
        XCTAssertEqual(actual, expected)
    }
    
    func testThatJPYAmountsKeepsZeroFractionDigits() {
        let actual = Amount(value: 1.234, in: Currency(code: "JPY")).value
        let expected = Decimal(value: 1, significantFractionDigits: 0)
        XCTAssertEqual(actual, expected)
    }
    
}
