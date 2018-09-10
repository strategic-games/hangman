import XCTest
import Utility
@testable import Games

class BegriffixTests: XCTestCase {
  func testKernel() {
    let k3 = Direction.Horizontal.kernel(3)
    XCTAssertEqual(k3.rows, 1)
    XCTAssertEqual(k3.columns, 3)
    let place = Place(start: Point(row: 3, column: 3), direction: .Vertical, count: 5)
    let k5 = place.kernel
    XCTAssertEqual(k5.rows, 5)
    XCTAssertEqual(k5.columns, 1)
  }
  func testPlaceToArea() {
    let place = Place(start: Point(row: 3, column: 3), direction: .Vertical, count: 5)
    let area = place.area
    XCTAssertEqual(area.rows, 3..<8)
    XCTAssertEqual(area.columns, 3..<4)
  }
  func testPerformance() {
    let startLetters: [[Unicode.Scalar?]] = [["l", "a"], ["e", "r"]]
    let player = Player()
    var game = Begriffix(startLetters: startLetters, starter: player.move, opponent: player.move)
    measure {
      _ = try? game?.play()
    }
  }
  /*func testColision() {
    let values = """
bravsten
s..et.a.
u..rö.b.
nutzholz
duzenden
e..ie.g.
dröhntet
...td...
"""
  }*/
  func testCollectionWord() {
    let x: [Character?] = [nil, "x", "y", "z", nil]
    XCTAssertEqual(x.indices(around: 2, surround: nil), 1..<4)
  }

}
