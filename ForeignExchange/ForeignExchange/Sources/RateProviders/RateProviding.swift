import Foundation

public protocol RateProviding {
        
    var ratesURL: URL { get }
    
    func parseRateResponse(_ data: Data) throws -> RatesSnapshot
    
}
