import Foundation

struct OpenExchangeRateProvider: RateProviding {
    
    struct APIKey {
        var value: Str
    }
    
    private var key: APIKey
    
    let supportedCurrencies: Set<Currency> = [
        .gbp,
        .eur,
        .usd,
        .chf,
    ]
    
    init(key: APIKey) {
        self.key = key
    }
    
}

extension OpenExchangeRateProvider {
    
    init(keyValue: String) {
        self.init(key: APIKey(value: keyValue))
    }
    
}
