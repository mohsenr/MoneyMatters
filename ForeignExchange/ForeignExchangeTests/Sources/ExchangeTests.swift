import XCTest
@testable import ForeignExchange

class ExchangeTests: XCTestCase {
    
    func testExchangeForwardsSupportedCurrenciesFromProvider() {
        let provider = MockProvider()
        
        provider.supportedCurrencies = Set((0..<Int.random(in: 2...10)).map { _ in
            Currency.random()
        })
        
        let exchange = Exchange(withRatesFrom: provider)
        XCTAssertEqual(exchange.supportedCurrencies, provider.supportedCurrencies)
    }
    
}

private class MockProvider: RateProviding {
    
    var supportedCurrencies: Set<Currency> = []
    
}

private extension Currency {
    
    static func random() -> Currency {
        return Currency(code: String(UUID().uuidString.prefix(3)))
    }
    
}
