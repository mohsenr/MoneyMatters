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
    
    public init() {
        
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
        
        return Dictionary(costLines, uniquingKeysWith: { $0 + $1 }).filter { _, value in value != 0}
    }
    
}
