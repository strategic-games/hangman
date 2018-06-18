import XCTest

extension BoardGamesTests {
    static let __allTests = [
        ("testExample", testExample),
    ]
}

extension DimensionsTests {
    static let __allTests = [
        ("testAddition", testAddition),
        ("testComparation", testComparation),
        ("testContains", testContains),
        ("testCount", testCount),
        ("testIndex", testIndex),
        ("testSubtraction", testSubtraction),
    ]
}

extension MatrixTests {
    static let __allTests = [
        ("testConv2", testConv2),
        ("testInitArrays", testInitArrays),
        ("testInitString", testInitString),
        ("testSubscript", testSubscript),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BoardGamesTests.__allTests),
        testCase(DimensionsTests.__allTests),
        testCase(MatrixTests.__allTests),
    ]
}
#endif
