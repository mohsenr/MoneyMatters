import XCTest
import TestingSupport
import Accountant

private struct MockExpenditure: Expenditure {
    var amount: Double
    var payer: Int
    var beneficiaries: Set<Int>
}

private struct MockTransfer: Transfer, Equatable {
    var from: Int
    var to: Int
    var amount: Double
}

class CostDividerTests: XCTestCase {
    
    let divider = CostDivider(significantFractionDigits: 2)
    
    // MARK: balances
    
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
    
    // MARK: settlement
    
    func testThatEmptyBalancesResultInNoTransfers() {
        let transfers = divider.suggestedTransfersToSettle(balances: [:], type: MockTransfer.self)
        XCTAssertTrue(transfers.isEmpty)
    }
    
    func testThatSettlingSingleBalanceResultsInEmptyIfBalanceZero() {
        let transfers = self.divider.suggestedTransfersToSettle(balances: [1:0], type: MockTransfer.self)
        XCTAssertTrue(transfers.isEmpty)
    }
    
    func testThatTryingToSettleSingleBalanceThrowsIfTotalsToZero() {
        XCTAssertFatalError {
            _ = self.divider.suggestedTransfersToSettle(balances: [1:1], type: MockTransfer.self)
        }
    }
    
    func testThatTryingToSettleThrowsIfTotalIsNotZero() {
        XCTAssertFatalError {
            _ = self.divider.suggestedTransfersToSettle(balances: [1:1, 2:0], type: MockTransfer.self)
        }
    }
    
    func testSettlingWithSinglePayment() {
        let balances = [
            1: 1.37,
            2: -1.37,
            ]
        let transfers = self.divider.suggestedTransfersToSettle(balances: balances, type: MockTransfer.self)
        let expected = [
            MockTransfer(from: 2, to: 1, amount: 1.37),
            ]
        XCTAssertTrue(transfers.elementsEqual(expected))
    }
    
    func testSettlingWithTwoPayments() {
        let balances = [
            1: 1.37,
            2: -2.41,
            3: 1.04,
            ]
        let transfers = self.divider.suggestedTransfersToSettle(balances: balances, type: MockTransfer.self)
        let expected = [
            MockTransfer(from: 2, to: 3, amount: 1.04),
            MockTransfer(from: 2, to: 1, amount: 1.37),
            ]
        XCTAssertTrue(transfers.elementsEqual(expected))
    }
    
}
