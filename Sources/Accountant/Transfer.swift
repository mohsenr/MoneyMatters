import Foundation

public protocol Transfer {
    associatedtype Entity
    
    init(from payer: Entity, to payee: Entity, amount: Double)
}
