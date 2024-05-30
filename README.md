# _cuid2_ in Swift

The original implementation in js: [https://github.com/paralleldrive/cuid2](https://github.com/paralleldrive/cuid2)

`cuid2` is a possible replacement to globally unique identifiers such as UUID and such. The length of such an id is configurable and can be easier to copy-paste manually.

Here is an example of the `cuid2` with its default length: `lnapog2xtrbfatrw5qtrpvs6`.

To learn more, please follow the link to the reference implementation in javascript.

## Installation

Please add this dependency to your `Package.swift` to use this library:

```swift
.package(url: "https://github.com/RussBaz/cuid2.git", from: "0.0.1"),
```

and then add the dependency to the target:

```swift
.product(name: "cuid2", package: "cuid2"),
```

## How to use

### As a library

```swift
import cuid2

let id = createId() // quickest way to create a one off id
isCuid2(id: id) // to verify if the string can possibly be cuid2

// Alternatively, you can customise how the ids a generated
// by providing a custom session counter, cuid length and a custom fingerprint
func createId(counter: Cuid2SessionCounter? = nil, length: Int? = nil, fingerprint: String? = nil) -> String { }

// If you need to create many ids
// 1. please create an instance of the generator
struct Cuid2Generator {
    // other code omitted

    init(counter: Cuid2SessionCounter? = nil, length: Int? = nil, fingerprint: String? = nil) { }

    // 2. and then use this method to create an array of ids
    func generate(times: Int) -> [String] { }

    // skipping more code
}
```

### As a CLI tool

Clone the repository, build the release build with `swift build -c release` from the project root. The `cuid2cli` is now ready for use in the `.build/<target-arch-platform>/release/` folder. Move it or copy it into the target destination.

```
USAGE: tool [--count <count>] [--include-line-number] [--length <length>] [--fingerprint <fingerprint>]

OPTIONS:
  -c, --count <count>     The number of times to repeat 'cuid2'. (default: 1)
  -i, --include-line-number
                          Include a line number with each repetition.
  -l, --length <length>   The 'cuid2' length in characters.
  -f, --fingerprint <fingerprint>
                          The custom fingerprint.
  -h, --help              Show help information.
```
