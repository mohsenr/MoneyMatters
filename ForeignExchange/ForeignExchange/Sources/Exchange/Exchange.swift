import Foundation
import RxSwift
import Support

public class Exchange {
    
    public struct Snapshot {
        
        var rates: [Currency: Double]
        
        public init(rates: [Currency: Double]) {
            self.rates = rates
        }
        
        var supportedCurrencies: Set<Currency> {
            return Set(rates.keys)
        }
        
        public func convert(unitOf source: Currency, to target: Currency) -> Double {
            guard let s = rates[source] else { Thread.fatalError("\(source) is not a supported currency") }
            guard let t = rates[target] else { Thread.fatalError("\(target) is not a supported currency") }
            return t/s
        }
        
    }
    
    private let provider: RateProviding
    
    public let snapshot: Observable<Snapshot>
    
    public var supportedCurrencies: Set<Currency> {
        return provider.supportedCurrencies
    }
    
    public init(withRatesFrom provider: RateProviding, fetch: @escaping (URL) -> Observable<Data>) {
        self.provider = provider
        self.snapshot = fetch(provider.ratesURL)
            .map { try provider.parseRateResponse($0) }
            .map { Snapshot(rates: $0) }
            .share(replay: 1, scope: .forever)
    }
    
}

public extension Exchange {
    
    enum BuiltInRateProvider {
        case openExchange(key: String)
    }
    
    public convenience init(provider: BuiltInRateProvider, fetch: @escaping (URL) -> Observable<Data>) {
        switch provider {
        case .openExchange(let key):
            self.init(withRatesFrom: OpenExchangeRateProvider(keyValue: key), fetch: fetch)
        }
    }
    
}
