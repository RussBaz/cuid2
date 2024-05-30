import ArgumentParser

import cuid2

@main
struct Tool: ParsableCommand {
    @Option(name: .shortAndLong, help: "The number of times to repeat 'cuid2'.")
    var count: Int = 1

    @Flag(name: .shortAndLong, help: "Include a line number with each repetition.")
    var includeLineNumber = false

    @Option(name: .shortAndLong, help: "The 'cuid2' length in characters.")
    var length: Int? = nil

    @Option(name: .shortAndLong, help: "The custom fingerprint.")
    var fingerprint: String? = nil

    func run() throws {
        let count = max(count, 1)
        let generator = Cuid2Generator(length: length, fingerprint: fingerprint)
        let results = generator.generate(times: count)

        for (i, result) in results.enumerated() {
            if includeLineNumber {
                print("\(i + 1): \(result)")
            } else {
                print(result)
            }
        }
    }
}
