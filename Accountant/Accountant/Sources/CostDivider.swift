import Foundation

public struct CostDivider<Entity: Hashable> {
    
    public struct Expenditure {
        var amount: Double
        var payer: Entity
        var beneficiaries: Set<Entity>
        
        public init(amount: Double, payer: Entity, beneficiaries: Set<Entity>) {
            precondition(!beneficiaries.isEmpty, "Expenditure must have at least one beneficiary.")
            self.amount = amount
            self.payer = payer
            self.beneficiaries = beneficiaries
        }
    }
    
    private var rounder: Rounder
    
    public init(significantFractionDigits: Int) {
        self.rounder = Rounder(fractionDigitsToKeep: significantFractionDigits)
    }
    
    public func balances(of expenditures: [Expenditure]) -> [Entity: Double] {
        let costLines = expenditures.lazy.flatMap { expenditure -> [(Entity, Double)] in
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
