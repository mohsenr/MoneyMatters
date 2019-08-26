import Foundation

extension Decimal {
    
    /// A `Decimal` equal to `value` up to `fractionDigits` digits.
    ///
    /// Setting `significantFractionDigits` to a negative value reduces accurace of significand:
    /// ```
    /// Decimal(value: 42, significantFractionDigits: -1) // == Decimal(40)
    /// ```
    ///
    /// - Parameter value: The value of the decimal.
    /// - Parameter significantFractionDigits: The number of significant digits.
    public init(value: Double, significantFractionDigits: Int) {
        let scale = pow(10, Double(significantFractionDigits))
        let significand = Decimal(Int(value * scale))
        self.init(
            sign: significand.sign,
            exponent: -significantFractionDigits,
            significand: significand
        )
    }
    
}
