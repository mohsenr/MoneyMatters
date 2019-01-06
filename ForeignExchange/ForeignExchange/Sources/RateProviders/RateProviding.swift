import Foundation

public protocol RateProviding {
    
    var supportedCurrencies: Set<Currency> { get }
    
}
