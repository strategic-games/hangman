import XCTest
@testable import Utility

class WordListTests: XCTestCase {
  func testAllFilesLoad() {
    WordList.allCases.forEach {XCTAssertNotNil($0.load())}
  }
}
