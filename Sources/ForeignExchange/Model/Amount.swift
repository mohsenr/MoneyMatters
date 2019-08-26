import Foundation
import Support

/// A monetary amount in a given currency.
public struct Amount: Equatable {
    public var value: Decimal
    public var currency: Currency
    
    public init(value: Decimal, currency: Currency) {
        self.value = value
        self.currency = currency
    }
}

extension Amount {
    
    /// Creates an amount with the specified value and currency.
    ///
    /// The amount only retains the significant digits expected for the specified currency.
    ///
    /// - Parameter value: The value of the amount.
    /// - Parameter currency: The currency of the amount.
    public init(value: Double, in currency: Currency) {
        let significantFractionDigits = Self.standardSignificantFractionDigits(for: currency)
        self.init(
            value: Decimal(value: value, significantFractionDigits: significantFractionDigits),
            currency: currency
        )
    }
    
}

private extension Amount {
    
    static var sema = DispatchSemaphore(value: 1)
    static var significantDigits = [Currency: Int]()
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyISOCode
        return formatter
    }()
    static func standardSignificantFractionDigits(for currency: Currency) -> Int {
        sema.wait()
        defer { sema.signal() }
        
        if let digits = significantDigits[currency] {
            return digits
        } else {
            formatter.currencyCode = currency.code
            let digits = formatter.maximumFractionDigits
            significantDigits[currency] = digits
            return digits
        }
    }
    
}
