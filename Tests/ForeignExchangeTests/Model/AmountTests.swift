import XCTest
@testable import ForeignExchange

class AmountTests: XCTestCase {
    
    func testThatInitWithDoubleAndNoFractionDigits() {
        let actual = Amount(value: 1.234, significantFractionDigits: 0, in: .gbp)
        let expected = Amount(value: Decimal(integerLiteral: 1), currency: .gbp)
        
        XCTAssertEqual(actual, expected)
    }
    
}
