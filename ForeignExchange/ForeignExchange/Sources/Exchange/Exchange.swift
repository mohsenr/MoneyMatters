import Foundation

public class Exchange {
    
    public init(ratesFrom providing: RateProviding) {
        
    }
    
}

public extension Exchange {
    
    enum BuiltInRateProvider {
        case openExchange(key: String)
    }
    
    public convenience init(provider: BuiltInRateProvider) {
        switch provider {
        case .openExchange(let key):
            self.init(ratesFrom: OpenExchangeRateProvider(keyValue: key))
        }
    }
    
}
