import Foundation

public struct RatesSnapshot: Equatable {
    
    var rates: [Currency: Double]
    
    public init(rates: [Currency: Double]) {
        self.rates = rates
    }
    
    var supportedCurrencies: Set<Currency> {
        return Set(rates.keys)
    }
    
    public func price(ofUnit source: Currency, in target: Currency) -> Double {
        guard let s = rates[source] else { Thread.fatalError("\(source) is not a supported currency") }
        guard let t = rates[target] else { Thread.fatalError("\(target) is not a supported currency") }
        return t/s
    }
    
}
