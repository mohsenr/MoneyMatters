import XCTest
import TestingSupport
import Accountant

private struct MockExpenditure: Expenditure {
    var amount: Double
    var payer: Int
    var beneficiaries: Set<Int>
}

class CostDividerTests: XCTestCase {
    
    let divider = CostDivider(significantFractionDigits: 2)
    
    func testThatBalancesAreEmptyWithoutAnyExpenses() {
        let balances = divider.balances(of: Array<MockExpenditure>())
        XCTAssertTrue(balances.isEmpty)
    }
    
    func testUsingExpenditureWithoutBeneficiaryTraps() {
        XCTAssertFatalError {
            let expenditure = MockExpenditure(amount: 1, payer: 1, beneficiaries: [])
            _ = self.divider.balances(of: [expenditure])
        }
    }
    
    func testThatASingleEntityExpenditureDoesNotProduceABalance() {
        let expenditure = MockExpenditure(amount: 2, payer: 1, beneficiaries: [1])
        
        let balances = divider.balances(of: [expenditure])
        XCTAssertTrue(balances.isEmpty)
    }
    
    func testThatPayingForAnotherEntityIsCapturedInTheBalance() {
        let expenditure = MockExpenditure(amount: 2, payer: 1, beneficiaries: [2])
        
        let actual = divider.balances(of: [expenditure])
        let expected = [
            1: 2.0,
            2: -2.0,
            ]
        XCTAssertEqual(actual, expected)
    }
    
    func testThatPayingForSelfAndAnotherEntityIsCapturedInTheBalance() {
        let expenditure = MockExpenditure(amount: 2, payer: 1, beneficiaries: [1,2])
        
        let actual = divider.balances(of: [expenditure])
        let expected = [
            1: 1.0,
            2: -1.0,
            ]
        XCTAssertEqual(actual, expected)
    }
    
    func testThatTotalOfSignificantDigitsOfBalanceAreZero() {
        let expenditure = MockExpenditure(amount: 2.00, payer: 1, beneficiaries: [1,2,3])
        
        let sumOfBalances = divider.balances(of: [expenditure]).values.map { Int($0*100) }.reduce(0, +)
        XCTAssertEqual(0, sumOfBalances)
    }
    
}
