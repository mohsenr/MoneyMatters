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
