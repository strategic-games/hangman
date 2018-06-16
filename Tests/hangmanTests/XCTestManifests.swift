import XCTest

extension hangmanTests {
    static let __allTests = [
        ("testMatch", testMatch),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(hangmanTests.__allTests),
    ]
}
#endif
