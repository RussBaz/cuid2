import Foundation

import BigInt
import CryptoSwift

// Letters from a to z in ASCII
let alphabet = (97 ..< 123).map { String(UnicodeScalar(UInt8($0))) }
var randomLetter: String { alphabet.randomElement()! }

public final class Cuid2SessionCounter {
    private var value: Int

    private static let initialCountMax = 476_782_367

    public init(initial count: Int? = nil) {
        value = count ?? Cuid2SessionCounter.randomCount
    }

    public func next() -> Int {
        value += 1
        return value
    }

    public static var randomCount: Int { Int.random(in: 0 ..< initialCountMax) }
}

public struct Cuid2Generator {
    private let counter: Cuid2SessionCounter
    private let salt: String
    private let fingerprint: String

    public let length: Int

    public static let defaultLength = 24
    public static let minLength = 2
    public static let maxLength = 98
    public static let bigLength = 32

    public init(counter: Cuid2SessionCounter? = nil, length: Int? = nil, fingerprint: String? = nil) {
        self.length = min(max(length ?? Cuid2Generator.defaultLength, Cuid2Generator.minLength), Cuid2Generator.maxLength)
        self.counter = counter ?? Cuid2SessionCounter()
        salt = Cuid2Generator.createEntropy(length: self.length)
        self.fingerprint = fingerprint ?? Cuid2Generator.createFingerprint()
    }

    public func generate() -> String {
        let time = String(Int64(Date.now.timeIntervalSince1970) * 1000, radix: 36)

        let input = time + salt + String(counter.next(), radix: 36) + fingerprint
        let hashed = Cuid2Generator.hash(input: input)

        return "\(randomLetter)\(hashed.dropFirst().prefix(length - 1))"
    }

    public func generate(times: Int) -> [String] {
        let times = max(times, 1)
        return Array(repeating: "", count: times).map { _ in generate() }
    }

    static func hash(input: String) -> String {
        let hasher = SHA3(variant: .sha512)
        let data = Data(hasher.calculate(for: Array(input.utf8)))
        let value = BigInt(data)

        return String(String(value, radix: 36).dropFirst())
    }

    static func createEntropy(length times: Int = bigLength) -> String {
        let times = max(times, 1)

        var entropy = ""

        for _ in 0 ..< times {
            entropy += String(UInt8.random(in: 0 ..< 36), radix: 36)
        }

        return entropy
    }

    static func createFingerprint(from data: String? = nil) -> String {
        let hashed: String

        let entropy = createEntropy(length: Cuid2Generator.bigLength)

        if let data {
            hashed = hash(input: data + entropy)
        } else {
            let id = String(ProcessInfo.processInfo.processIdentifier)
            let hostname = ProcessInfo.processInfo.hostName
            let env = ProcessInfo.processInfo.environment.keys.joined()

            let data = id + hostname + env

            hashed = hash(input: data + entropy)
        }

        return String(hashed.prefix(Cuid2Generator.bigLength))
    }
}

public func createId(counter: Cuid2SessionCounter? = nil, length: Int? = nil, fingerprint: String? = nil) -> String {
    Cuid2Generator(counter: counter, length: length, fingerprint: fingerprint).generate()
}

public func isCuid2(id: String, minLength: Int = Cuid2Generator.minLength, maxLength: Int = Cuid2Generator.maxLength) -> Bool {
    let minLength = max(minLength, Cuid2Generator.minLength)
    let maxLength = min(maxLength, Cuid2Generator.maxLength)

    let length = id.count

    guard length >= minLength, length <= maxLength else { return false }
    guard id.utf8.allSatisfy({ ($0 > 47 && $0 < 58) || ($0 > 64 && $0 < 91) || ($0 > 96 && $0 < 123) }) else { return false }

    return true
}
