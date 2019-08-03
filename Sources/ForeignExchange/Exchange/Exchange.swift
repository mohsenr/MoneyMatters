import Foundation
import Combine
import Support

public class Exchange {
    
    private let provider: RateProviding
    
    public let rates: AnyPublisher<RatesSnapshot, Error>
    
    public init(withRatesFrom provider: RateProviding, fetch: @escaping (URL) -> AnyPublisher<Data, Error>) {
        self.provider = provider
        self.rates = fetch(provider.ratesURL)
            .tryMap { try provider.parseRateResponse($0) }
            .share()
            .eraseToAnyPublisher()
    }
    
}

extension Exchange {
    
    public enum BuiltInRateProvider {
        case openExchange(key: String)
    }
    
    public convenience init(provider: BuiltInRateProvider, fetch: @escaping (URL) -> AnyPublisher<Data, Error>) {
        switch provider {
        case .openExchange(let key):
            self.init(withRatesFrom: OpenExchangeRateProvider(keyValue: key), fetch: fetch)
        }
    }
    
}
