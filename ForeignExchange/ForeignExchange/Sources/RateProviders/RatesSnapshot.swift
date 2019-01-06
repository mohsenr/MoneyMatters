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

extension RatesSnapshot: Codable {
    
    private struct RawResponse: Codable {
        var rates: [String: Double]
    }

    public init(from decoder: Decoder) throws {
        let raw = try RawResponse(from: decoder)
        self.init(
            rates: Dictionary(uniqueKeysWithValues: raw.rates.map { (Currency(code: $0.key), $0.value) })
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        let raw = RawResponse(
            rates: Dictionary(uniqueKeysWithValues: rates.map { ($0.key.code, $0.value) })
        )
        try raw.encode(to: encoder)
    }
    
}
