@testable import cuid2
import XCTest

final class cuid2Tests: XCTestCase {
    func testEntropyWorks() throws {
        let result1 = Cuid2Generator.createEntropy()
        let result2 = Cuid2Generator.createEntropy(length: 8)

        XCTAssertEqual(result1.count, Cuid2Generator.bigLength)
        XCTAssertEqual(result2.count, 8)
    }

    func testCounter() throws {
        let counter1 = Cuid2SessionCounter()

        let previousValue = counter1.next()
        let nextValue = counter1.next()
        let difference = nextValue - previousValue

        XCTAssertEqual(difference, 1)

        let counter2 = Cuid2SessionCounter(initial: 12)

        XCTAssertEqual(counter2.next(), 13)
    }

    func testCuid2() throws {
        let counter = Cuid2SessionCounter(initial: 256)

        let id = createId(counter: counter, length: 18, fingerprint: "hello world 12")

        XCTAssertTrue(isCuid2(id: id, minLength: 1, maxLength: 32))
        XCTAssertEqual(counter.next(), 258)
        XCTAssertEqual(id.count, 18)

        let id2 = createId()

        XCTAssertTrue(isCuid2(id: id2, minLength: 0, maxLength: 32))
        XCTAssertEqual(counter.next(), 259)
        XCTAssertEqual(id2.count, Cuid2Generator.defaultLength)

        XCTAssertFalse(isCuid2(id: id2, minLength: Cuid2Generator.defaultLength + 1, maxLength: Cuid2Generator.maxLength))
        XCTAssertFalse(isCuid2(id: id2, minLength: 2, maxLength: Cuid2Generator.defaultLength - 1))

        let id3 = createId(length: 34)

        XCTAssertTrue(isCuid2(id: id3, minLength: 34, maxLength: 34))
        XCTAssertEqual(counter.next(), 260)
        XCTAssertEqual(id3.count, 34)
    }
}
