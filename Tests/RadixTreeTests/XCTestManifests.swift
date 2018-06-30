import XCTest

extension RadixTests {
    static let __allTests = [
        ("testAnagramm", testAnagramm),
        ("testAtomar", testAtomar),
        ("testDescending", testDescending),
        ("testDict", testDict),
        ("testInsert", testInsert),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RadixTests.__allTests),
    ]
}
#endif
