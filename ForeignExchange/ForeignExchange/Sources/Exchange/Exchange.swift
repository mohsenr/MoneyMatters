import Foundation

public class Exchange {
    
    private let provider: RateProviding
    
    public var supportedCurrencies: Set<Currency> {
        return provider.supportedCurrencies
    }
    
    public init(withRatesFrom provider: RateProviding) {
        self.provider = provider
    }
    
}

public extension Exchange {
    
    enum BuiltInRateProvider {
        case openExchange(key: String)
    }
    
    public convenience init(provider: BuiltInRateProvider) {
        switch provider {
        case .openExchange(let key):
            self.init(withRatesFrom: OpenExchangeRateProvider(keyValue: key))
        }
    }
    
}
