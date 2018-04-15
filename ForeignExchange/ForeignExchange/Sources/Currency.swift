import Foundation

public struct Currency: Hashable {
    
    public let code: String
    
    public init(code: String) {
        self.code = code.uppercased()
    }
    
}
