import Foundation

public struct Currency: Hashable {
    
    public let code: String
    
    public init(code: String) {
        self.code = code.uppercased()
    }
    
}

extension Currency: Codable {
    
    public init(from decoder: Decoder) throws {
        try self.init(code: String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try code.encode(to: encoder)
    }
    
}

extension Currency {
    
    static let eur = Currency(code: "EUR")
    
    static let gbp = Currency(code: "GBP")
    
    static let usd = Currency(code: "USD")
    
    static let chf = Currency(code: "CHF")
    
}
