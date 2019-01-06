import Foundation

public struct Currency: Hashable {
    
    public let code: String
    
    public init(code: String) {
        self.code = code.uppercased()
    }
    
}

extension Currency {
    
    static let eur = Currency(code: "EUR")
    
    static let gbp = Currency(code: "GBP")
    
    static let usd = Currency(code: "USD")
    
    static let chf = Currency(code: "CHF")
    
}
