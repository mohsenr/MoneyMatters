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
    
    func parseRateResponse(_ data: Data) throws -> [Currency: Double] {
        let response = try JSONDecoder().decode(RateResponse.self, from: data)
        return Dictionary(uniqueKeysWithValues: response.rates.map { (Currency(code: $0.key), $0.value) })
    }
    
}

extension OpenExchangeRateProvider {
    
    init(keyValue: String) {
        self.init(key: APIKey(value: keyValue))
    }
    
}

private struct RateResponse: Decodable {
    var rates: [String: Double]
}
