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
    XCTAssert(sizes[0].count == 30)
    XCTAssert(sizes[1].count == 64)
    XCTAssert(sizes[2].count == 40)
  }
  func testContains() {
    let p = Position(4, 5)
    XCTAssert(sizes[0].contains(p))
    XCTAssert(sizes[1].contains(p))
    XCTAssertFalse(sizes[2].contains(p))
  }
  func testIndex() {
    let p = Position(3, 3)
    XCTAssert(sizes[0].index(p) == 21)
    XCTAssert(sizes[1].index(p) == 27)
    XCTAssert(sizes[2].index(p) == 15)
  }
  func testComparation() {
    XCTAssert(sizes[0] < sizes[1])
    XCTAssertFalse(sizes[0] < sizes[2])
    XCTAssertFalse(sizes[2] < sizes[1])
  }
  func testAddition() {
    XCTAssert(sizes[0]+sizes[1] == Dimensions(13, 14))
    XCTAssert(sizes[1]+sizes[2] == Dimensions(18, 12))
    XCTAssert(sizes[2]+3 == Dimensions(13, 7))
  }
  func testSubtraction() {
    XCTAssert(sizes[1]-sizes[0] == Dimensions(3, 2))
  }

}
