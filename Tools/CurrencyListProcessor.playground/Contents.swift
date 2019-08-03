import Foundation

extension JSONDecoder {
    
    enum Errors: Error {
        case fileNotFound
    }

    func decode<T: Decodable>(_ type: T.Type, from name: String) throws -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw Errors.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return try self.decode(type, from: data)
    }

}

struct Failable<Wrapped: Decodable>: Decodable {
    var value: Wrapped?
    
    init(from decoder: Decoder) throws {
        self.value = try? decoder.singleValueContainer().decode(Wrapped.self)
    }
}

struct Standard: Decodable {
    struct Currency: Decodable {
        private enum CodingKeys: String, CodingKey {
            case code = "Ccy"
            case name = "CcyNm"
        }
        var code: String
        var name: String
    }
    private struct Raw: Decodable {
        struct Table: Decodable {
            var CcyNtry: [Failable<Currency>]
        }
        struct Iso: Decodable {
            var CcyTbl: Table
        }
        var ISO_4217: Iso
    }
    var currencies: [Currency]
    
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Raw.self)
        currencies = raw.ISO_4217.CcyTbl.CcyNtry.compactMap { $0.value }
    }
}

struct FXService: Decodable {
    // working around a bug in swift: The following crashes if `count` > 100:
    //
    // ```
    // let dict = Dictionary.init(uniqueKeysWithValues: (1...count).map { ($0, $0)})
    // ```
    //
    // so let’s split it :-)
    var symbols1: [String: String]
    var symbols2: [String: String]
    
    func supports(_ code: String) -> Bool {
        return (symbols1[code] ?? symbols2[code]) != nil
    }
}

struct Unified: Codable {
    struct Currency: Codable {
        var code: String
        var name: String
    }
    var currencies: [Currency]
}

let decoder = JSONDecoder()

let standard = try! decoder.decode(Standard.self, from: "standard")
let fx = try! decoder.decode(FXService.self, from: "supported")

var encountered = Set<String>()
var unified = [Unified.Currency]()
for currency in standard.currencies {
    guard fx.supports(currency.code), !encountered.contains(currency.code) else { continue }
    encountered.insert(currency.code)
    unified.append(Unified.Currency(code: currency.code, name: currency.name))
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let processedData = try! encoder.encode(Unified(currencies: unified))
print(String(data: processedData, encoding: .utf8)!)
