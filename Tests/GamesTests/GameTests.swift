import XCTest
import Utility
@testable import Games

class BegriffixTests: XCTestCase {
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
  func testWordInLine() {
    let pattern: Begriffix.Pattern = [nil, "x", "y", "z", nil]
    let word: Begriffix.Word = ["x", "y", "z"]
    XCTAssertEqual(Begriffix.word(in: pattern, around: 2), word)
  }
  func testPerformance() {
    let radix = Radix()
    let startLetters = "laer"
    let player = Player(radix)
    let game = Begriffix(startLetters: startLetters, starter: player.move, opponent: player.move)
    measure {
      for _ in game {}
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
}
