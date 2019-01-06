import Foundation

struct OpenExchangeRateProvider: RateProviding {
    
    struct APIKey {
        var value: String
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
    
    var ratesURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openexchangerates.org"
        components.path = "/api/latest.json"
        components.queryItems = [
            URLQueryItem(name: "app_id", value: key.value),
            URLQueryItem(name: "symbols", value: supportedCurrencies.map { $0.code }.joined(separator: ",")),
        ]
        return components.url!
    }
    
    func parseRateResponse(_ data: Data) throws -> RatesSnapshot {
        // As it happens, our transport JSON is compatible with `RatesSnapshot` without adaptation.
        return try JSONDecoder().decode(RatesSnapshot.self, from: data)
    }
    
}

extension OpenExchangeRateProvider {
    
    init(keyValue: String) {
        self.init(key: APIKey(value: keyValue))
    }
    
}
