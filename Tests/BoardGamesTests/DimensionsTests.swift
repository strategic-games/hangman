import XCTest
@testable import BoardGames

class DimensionsTests: XCTestCase {
  var sizes = [Dimensions]()
  override func setUp() {
    sizes = [
      Dimensions(5, 6),
      Dimensions(8),
      Dimensions(10, 4)
    ]
  }

  override func tearDown() {
  }

  func testCount() {
    XCTAssertEqual(sizes[0].count, 30)
    XCTAssertEqual(sizes[1].count, 64)
    XCTAssertEqual(sizes[2].count, 40)
  }
  func testContains() {
    let p = Position(4, 5)
    XCTAssert(sizes[0].contains(p))
    XCTAssert(sizes[1].contains(p))
    XCTAssertFalse(sizes[2].contains(p))
  }
  func testIndex() {
    let p = Position(3, 3)
    XCTAssertEqual(sizes[0].index(p), 21)
    XCTAssertEqual(sizes[1].index(p), 27)
    XCTAssertEqual(sizes[2].index(p), 15)
  }
  func testComparation() {
    XCTAssertLessThan(sizes[0], sizes[1])
    XCTAssertFalse(sizes[0] < sizes[2])
    XCTAssertFalse(sizes[2] < sizes[1])
  }
  func testAddition() {
    XCTAssertEqual(sizes[0]+sizes[1], Dimensions(13, 14))
    XCTAssertEqual(sizes[1]+sizes[2], Dimensions(18, 12))
    XCTAssertEqual(sizes[2]+3, Dimensions(13, 7))
  }
  func testSubtraction() {
    XCTAssertEqual(sizes[1]-sizes[0], Dimensions(3, 2))
  }

}
