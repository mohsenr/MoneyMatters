import XCTest
import RxSwift
@testable import ForeignExchange

class ExchangeTests: XCTestCase {
    
    func testExchangeForwardsSupportedCurrenciesFromProvider() {
        let provider = MockProvider(supportedCurrencies: Set((0..<Int.random(in: 2...10)).map { _ in
            Currency.random()
        }))
        
        let exchange = Exchange(withRatesFrom: provider) { _ in .empty() }
        XCTAssertEqual(exchange.supportedCurrencies, provider.supportedCurrencies)
    }
    
    func testFetchingRatesRelativeToBase() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .usd])
        
        let exchange = Exchange(withRatesFrom: provider) { _ in .just(Data()) }
        
        var fetchedRate: Double?
        let disposable = exchange.convert(unitOf: .usd, to: .gbp).subscribe(onNext: { rate in
            fetchedRate = rate
        })
        disposable.dispose()
        
        XCTAssertEqual(fetchedRate, 0.785545)
    }
    
    func testFetchingRatesRelativeToNoneBase() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        let exchange = Exchange(withRatesFrom: provider) { _ in .just(Data()) }
        
        var fetchedRate = 0.0
        let disposable = exchange.convert(unitOf: .eur, to: .gbp).subscribe(onNext: { rate in
            fetchedRate = rate
        })
        disposable.dispose()
        
        XCTAssertEqual(fetchedRate, 0.895172, accuracy: 0.0001)
    }
    
    func testConversionFailsIfUnitCurrencyUnknown() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        let exchange = Exchange(withRatesFrom: provider) { _ in .just(Data()) }
        
        var error: Error?
        let disposable = exchange.convert(unitOf: .chf, to: .gbp).subscribe(onError: { error = $0 })
        disposable.dispose()
        
        XCTAssertNotNil(error)
    }
    
    func testConversionFailsIfTargetCurrencyUnknown() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        let exchange = Exchange(withRatesFrom: provider) { _ in .just(Data()) }
        
        var error: Error?
        let disposable = exchange.convert(unitOf: .gbp, to: .chf).subscribe(onError: { error = $0 })
        disposable.dispose()
        
        XCTAssertNotNil(error)
    }
    
    func testDataIsNotFetchedOnceIfNotQueried() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        var subscribeCount = 0
        _ = Exchange(withRatesFrom: provider) { _ in
            return Observable.deferred {
                subscribeCount += 1
                return .just(Data())
            }
        }
        
        XCTAssertEqual(subscribeCount, 0)
    }
    
    func testDataIsFetchedOnceIfQueriedMultipleTimesAfterFetchCompletes() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        var subscribeCount = 0
        let exchange = Exchange(withRatesFrom: provider) { _ in
            return Observable.deferred {
                subscribeCount += 1
                return .just(Data())
            }
        }

        let bag = DisposeBag()
        exchange.convert(unitOf: .eur, to: .gbp).subscribe { _ in }.disposed(by: bag)
        exchange.convert(unitOf: .eur, to: .gbp).subscribe { _ in }.disposed(by: bag)
        
        XCTAssertEqual(subscribeCount, 1)
    }
    
    func testDataIsFetchedOnceIfQueriedMultipleTimesBeforeFetchCompletes() {
        let provider = MockProvider(supportedCurrencies: [.gbp, .eur])
        
        let subject = PublishSubject<Data>()
        var subscribeCount = 0
        let exchange = Exchange(withRatesFrom: provider) { _ in
            return Observable.deferred {
                subscribeCount += 1
                return subject
            }
        }

        let bag = DisposeBag()
        exchange.convert(unitOf: .eur, to: .gbp).subscribe { _ in }.disposed(by: bag)
        exchange.convert(unitOf: .eur, to: .gbp).subscribe { _ in }.disposed(by: bag)
        
        XCTAssertEqual(subscribeCount, 1)
    }
    
}

private struct MockProvider: RateProviding {
    
    var supportedCurrencies: Set<Currency>
    
    var ratesURL: URL {
        return URL(string: "https://example.com")!
    }
    
    func parseRateResponse(_ data: Data) throws -> [Currency: Double] {
        return [
            Currency(code: "EUR"): 0.877535,
            Currency(code: "GBP"): 0.785545,
            Currency(code: "USD"): 1,
        ]
    }
    
}

private extension Currency {
    
    static func random() -> Currency {
        return Currency(code: String(UUID().uuidString.prefix(3)))
    }
    
}
