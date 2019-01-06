import Foundation
import RxSwift
import Support

public class Exchange {
    
    private let provider: RateProviding
    
    public let rates: Observable<RatesSnapshot>
    
    public init(withRatesFrom provider: RateProviding, fetch: @escaping (URL) -> Observable<Data>) {
        self.provider = provider
        self.rates = fetch(provider.ratesURL)
            .map { try provider.parseRateResponse($0) }
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
