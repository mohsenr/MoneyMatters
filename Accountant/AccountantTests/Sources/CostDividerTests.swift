import XCTest
import Accountant

class CostDividerTests: XCTestCase {
    
    let divider = CostDivider<Int>(significantFractionDigits: 2)
    
    func testThatBalancesAreEmptyWithoutAnyExpenses() {
        let balances = divider.balances(of: [])
        XCTAssertTrue(balances.isEmpty)
    }
    
    func testThatASingleEntityExpenditureDoesNotProduceABalance() {
        let expenditure = CostDivider.Expenditure(amount: 2, payer: 1, beneficiaries: [1])
        
        let balances = divider.balances(of: [expenditure])
        XCTAssertTrue(balances.isEmpty)
    }
    
    func testThatPayingForAnotherEntityIsCapturedInTheBalance() {
        let expenditure = CostDivider.Expenditure(amount: 2, payer: 1, beneficiaries: [2])
        
        let actual = divider.balances(of: [expenditure])
        let expected = [
            1: 2.0,
            2: -2.0,
            ]
        XCTAssertEqual(actual, expected)
    }
    
    func testThatPayingForSelfAndAnotherEntityIsCapturedInTheBalance() {
        let expenditure = CostDivider.Expenditure(amount: 2, payer: 1, beneficiaries: [1,2])
        
        let actual = divider.balances(of: [expenditure])
        let expected = [
            1: 1.0,
            2: -1.0,
            ]
        XCTAssertEqual(actual, expected)
    }
    
    func testThatTotalOfSignificantDigitsOfBalanceAreZero() {
        let expenditure = CostDivider.Expenditure(amount: 2.00, payer: 1, beneficiaries: [1,2,3])
        
        let sumOfBalances = divider.balances(of: [expenditure]).values.map { Int($0*100) }.reduce(0, +)
        XCTAssertEqual(0, sumOfBalances)
    }
    
}
