import XCTest
@testable import Utility
@testable import Games

class PlaceTests: XCTestCase {
  func testKernel() {
    let kern3 = Direction.horizontal.kernel(3)
    XCTAssertEqual(kern3.rows, 1)
    XCTAssertEqual(kern3.columns, 3)
    let place = Place(
      start: Point(row: 3, column: 3),
      direction: .vertical,
      count: 5
    )
    let kern5 = place.kernel
    XCTAssertEqual(kern5.rows, 5)
    XCTAssertEqual(kern5.columns, 1)
  }
  func testPlaceToArea() {
    let place = Place(
      start: Point(row: 3, column: 3),
      direction: .vertical,
      count: 5
    )
    let area = place.area
    XCTAssertEqual(area.rows, 3..<8)
    XCTAssertEqual(area.columns, 3..<4)
  }
}
