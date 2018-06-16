import XCTest

extension BoardGamesTests {
    static let __allTests = [
        ("testExample", testExample),
        ("testPerformanceExample", testPerformanceExample),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BoardGamesTests.__allTests),
    ]
}
#endif
