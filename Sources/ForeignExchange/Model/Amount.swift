import Foundation

public struct Amount: Equatable {
    public var value: Decimal
    public var currency: Currency
    
    public init(value: Decimal, currency: Currency) {
        self.value = value
        self.currency = currency
    }
}

extension Amount {
    
    public init(value: Double, significantFractionDigits: Int, in currency: Currency) {
        self.init(
            value: Decimal(value: value, significantFractionDigits: significantFractionDigits),
            currency: currency
        )
    }
    
}
