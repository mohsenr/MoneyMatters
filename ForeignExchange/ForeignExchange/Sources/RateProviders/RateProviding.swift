import Foundation

public protocol RateProviding {
    
    var supportedCurrencies: Set<Currency> { get }
    
    var ratesURL: URL { get }
    
    func parseRateResponse(_ data: Data) throws -> [Currency: Double]
    
}
