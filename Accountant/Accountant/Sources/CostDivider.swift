import Foundation
import Support

public struct CostDivider {
    
    private var rounder: Rounder
    
    public init(significantFractionDigits: Int) {
        self.rounder = Rounder(fractionDigitsToKeep: significantFractionDigits)
    }
    
    public func balances<E>(of expenditures: [E]) -> [E.Entity: Double] where E: Expenditure {
        guard expenditures.allSatisfy({ !$0.beneficiaries.isEmpty }) else {
            Thread.fatalError("All expenditures must have at least one beneficiary.")
        }
        
        let costLines = expenditures.lazy.flatMap { expenditure -> [(E.Entity, Double)] in
            let payerLines = [(expenditure.payer, expenditure.amount)]
            let individualAmount = -(expenditure.amount / Double(expenditure.beneficiaries.count))
            let beneficiaryLines = expenditure.beneficiaries.map {
                ($0, individualAmount)
            }
            return payerLines + beneficiaryLines
        }
        
        let rawBalances = Dictionary(costLines, uniquingKeysWith: { $0 + $1 })
        
        var carryOver = 0.0
        let roundedBalances = rawBalances.mapValues { rawBalance -> Double in
            let balance = rounder.round(rawBalance+carryOver)
            carryOver = rawBalance - balance
            return balance
        }
        return roundedBalances.filter { _, value in value != 0 }
    }
    
    public func suggestedTransfersToSettle<T>(balances: [T.Entity: Double], type: T.Type) -> [T] where T: Transfer {
        let total = rounder.round(balances.values.reduce(0, +))
        Thread.precondition(total == 0, "Balance total must be zero")
        
        var transfers = [T]()
        var remaining = balances
        
        while remaining.count > 1 {
            // Find the entity with least absolute balance.
            // We’ll create a payment against the highest opposite sign balance entity.
            // This will guarantee we can always remove `entityToClear`’s balance with one transfer.
            let (entityToClear, first) = remaining.element(ofPreferredElement: { abs($0) < abs($1) })!
            remaining.removeValue(forKey: entityToClear)
            
            guard first != 0 else { continue } // just remove this one without making a transfer
            
            let comparator: (Double, Double) -> Bool
            let makeTransfer: (T.Entity) -> T
            
            switch first {
            case ..<0:
                comparator = (>)
                makeTransfer = { T.init(from: entityToClear, to: $0, amount: -first) }
            default:
                comparator = (<)
                makeTransfer = { T.init(from: $0, to: entityToClear, amount: first) }
            }
            
            let (destination, balance) = remaining.element(ofPreferredElement: comparator)!
            remaining[destination] = balance + first
            transfers.append(makeTransfer(destination))
        }
        
        return transfers
    }
    
}

private struct Rounder {
    
    private var factor: Double
    
    init(fractionDigitsToKeep: Int) {
        self.factor = pow(10, Double(fractionDigitsToKeep))
    }
    
    func round(_ value: Double) -> Double {
        return (value*factor).rounded()/factor
    }
    
}

private extension Dictionary {
    
    func element(ofPreferredElement isPreferred: (Value, Value) -> Bool) -> (key: Key, value: Value)? {
        let result: (key: Key, value: Value)? = reduce(nil) { previous, current in
            guard let previous = previous else { return current }
            
            return isPreferred(current.value, previous.value) ? current : previous
        }
        
        return result
    }
    
}
