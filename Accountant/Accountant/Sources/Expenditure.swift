import Foundation

public protocol Expenditure {
    associatedtype Entity: Hashable
    
    var amount: Double { get }
    var payer: Entity { get }
    var beneficiaries: Set<Entity> { get }
}

