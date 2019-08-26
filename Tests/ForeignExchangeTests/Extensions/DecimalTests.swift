import XCTest
@testable import ForeignExchange

class DecimalTests: XCTestCase {
    
    func testThatInitWithDoubleAndNoFractionDigits() {
        let actual = Decimal(value: 1.234, significantFractionDigits: 0)
        assert(actual, equals: "1")
    }
    
    func testThatInitWithDoubleAndOneFractionDigits() {
        let actual = Decimal(value: 1.234, significantFractionDigits: 1)
        assert(actual, equals: "1.2")
    }
    
    func testThatInitWithDoubleAndTwoFractionDigits() {
        let actual = Decimal(value: 1.234, significantFractionDigits: 2)
        assert(actual, equals: "1.23")
    }
    
    func testThatInitWithDoubleAndThreeFractionDigits() {
        let actual = Decimal(value: 1.234, significantFractionDigits: 3)
        assert(actual, equals: "1.234")
    }
    
    func testThatInitWithDoubleAndFourFractionDigits() {
        let actual = Decimal(value: 1.234, significantFractionDigits: 4)
        assert(actual, equals: "1.2340")
    }
    
    func testThatInitWithDoubleAndNegativeFractionDigits() {
        let actual = Decimal(value: 12.34, significantFractionDigits: -1)
        assert(actual, equals: "10")
    }
    
}

private extension DecimalTests {
    
    func assert(_ actual: Decimal, equals rawValue: String, file: StaticString = #file, line: UInt = #line) {
        guard let expected = Decimal(string: rawValue) else {
            XCTFail("Expected value not a decimal: \(rawValue)", file: file, line: line)
            return
        }
        
        XCTAssertEqual(actual, expected, file: file, line: line)
    }
    
}
