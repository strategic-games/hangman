import XCTest
@testable import Utility

class Index2DTests: XCTestCase {
  var areas = [Area]()
  override func setUp() {
    let dimensions = [
      (5, 6),
      (8, 8),
      (10, 4)
    ]
    areas = dimensions.map {Area(rows: 0..<$0.0, columns: 0..<$0.1)}
  }

  func testCount() {
    XCTAssertEqual(areas[0].count, 30)
    XCTAssertEqual(areas[1].count, 64)
    XCTAssertEqual(areas[2].count, 40)
  }
  func testContains() {
    let p = Point(row: 4, column: 5)
    XCTAssert(areas[0].contains(point: p))
    XCTAssert(areas[1].contains(point: p))
    XCTAssertFalse(areas[2].contains(point: p))
  }
}
