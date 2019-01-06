import Foundation
import RxSwift

public class Exchange {
    
    private enum Errors: Error {
        case rateUnavailableForCurrency
    }
    
    private let provider: RateProviding
    private let rates: Observable<[Currency: Double]>
    
    public var supportedCurrencies: Set<Currency> {
        return provider.supportedCurrencies
    }
    
    public init(withRatesFrom provider: RateProviding, fetch: @escaping (URL) -> Observable<Data>) {
        self.provider = provider
        self.rates = fetch(provider.ratesURL)
            .map { try provider.parseRateResponse($0) }
            .share(replay: 1, scope: .forever)
    }
    
    /// Returns exchange rate, such that `1*base == rate*currency`
    func convert(unitOf source: Currency, to target: Currency) -> Observable<Double> {
        return rates
            .map { rates in
                guard let s = rates[source], let t = rates[target] else {
                    throw Errors.rateUnavailableForCurrency
                }
                return t/s
        }
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
