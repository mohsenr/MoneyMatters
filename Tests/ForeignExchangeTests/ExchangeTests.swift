import XCTest
import Combine
@testable import ForeignExchange

class ExchangeTests: XCTestCase {
    
    func testFetchingRatesRelativeToBase() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .usd])
        
        let exchange = Exchange(withRatesFrom: provider) { _ in Just(Data()).mapError(absurd).eraseToAnyPublisher() }
        
        var fetchedRate: Double?
        let cancellable = exchange.rates.sink(receiveCompletion: { _ in }) { rate in
            fetchedRate = rate.price(ofUnit: .usd, in: .gbp)
        }
        cancellable.cancel()
        
        XCTAssertEqual(fetchedRate, 0.785545)
    }
    
    func testFetchingRatesRelativeToNoneBase() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        let exchange = Exchange(withRatesFrom: provider) { _ in Just(Data()).mapError(absurd).eraseToAnyPublisher() }
        
        var fetchedRate = 0.0
        let cancellable = exchange.rates.sink(receiveCompletion: { _ in }) { rate in
            fetchedRate = rate.price(ofUnit: .eur, in: .gbp)
        }
        cancellable.cancel()
        
        XCTAssertEqual(fetchedRate, 0.895172, accuracy: 0.0001)
    }
    
    func testDataIsNotFetchedOnceIfNotQueried() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        var subscribeCount = 0
        _ = Exchange(withRatesFrom: provider) { _ in
            Deferred { () -> AnyPublisher<Data, Error> in
                subscribeCount += 1
                return Just(Data()).mapError(absurd).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
        }
        
        XCTAssertEqual(subscribeCount, 0)
    }
    
    func testDataIsFetchedOnceIfQueriedMultipleTimesAfterFetchCompletes() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        var subscribeCount = 0
        let exchange = Exchange(withRatesFrom: provider) { _ in
            Deferred { () -> AnyPublisher<Data, Error> in
                subscribeCount += 1
                return Just(Data()).mapError(absurd).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
        }

        let cancellables = [
            exchange.rates.sink(receiveCompletion: { _ in }) { _ in },
            exchange.rates.sink(receiveCompletion: { _ in }) { _ in },
        ]
        
        defer {
            cancellables.forEach { $0.cancel() }
        }
        
        XCTAssertEqual(subscribeCount, 1)
    }
    
    func testDataIsFetchedOnceIfQueriedMultipleTimesBeforeFetchCompletes() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        let subject = PassthroughSubject<Data, Error>()
        var subscribeCount = 0
        let exchange = Exchange(withRatesFrom: provider) { _ in
            Deferred { () -> AnyPublisher<Data, Error> in
                subscribeCount += 1
                return subject.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
        }
        
        let cancellables = [
            exchange.rates.sink(receiveCompletion: { _ in }) { _ in },
            exchange.rates.sink(receiveCompletion: { _ in }) { _ in },
        ]
        
        defer {
            cancellables.forEach { $0.cancel() }
        }
        
        XCTAssertEqual(subscribeCount, 1)
    }
    
}

private struct MockProvider: RateProviding {
    
    var supportedCurrencies: Set<Currency>
    
    var ratesURL: URL {
        return URL(string: "https://example.com")!
    }
    
    func parseRateResponse(_ data: Data) throws -> RatesSnapshot {
        return RatesSnapshot(date: Date(), rates: [
            Currency(code: "EUR"): 0.877535,
            Currency(code: "GBP"): 0.785545,
            Currency(code: "USD"): 1,
        ])
    }
    
}

private func absurd<T>(_ never: Never) -> T {}
