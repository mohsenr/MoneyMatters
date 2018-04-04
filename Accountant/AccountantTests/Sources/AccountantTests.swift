import XCTest
@testable import Accountant

class AccountantTests: XCTestCase {
    
    func testThatTargetBuilds() {
        XCTAssertTrue(Accountant().isConstructed)
    }
    
}
