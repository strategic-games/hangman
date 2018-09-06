import XCTest
@testable import Hangman

class BegriffixTests: XCTestCase {
  func testStartLetters() {
    Begriffix.startLetters.forEach { x in
      XCTAssertEqual(String(describing: x).count, 4)
    }
  }
  func testKernel() {
    let k3 = Begriffix.Direction.Horizontal.kernel(3)
    XCTAssertEqual(k3.rows, 1)
    XCTAssertEqual(k3.columns, 3)
    let place = Begriffix.Place(start: Point(row: 3, column: 3), direction: .Vertical, count: 5)
    let k5 = place.kernel
    XCTAssertEqual(k5.rows, 5)
    XCTAssertEqual(k5.columns, 1)
  }
  func testPlaceToArea() {
    let place = Begriffix.Place(start: Point(row: 3, column: 3), direction: .Vertical, count: 5)
    let area = place.area
    XCTAssertEqual(area.rows, 3..<8)
    XCTAssertEqual(area.columns, 3..<4)
  }
  func testPerformance() {
    let b = Bundle(for: Radix.self)
    guard let url = b.url(forResource: "dictionaries/german", withExtension: "txt") else {return}
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {return}
    let radix = Radix(text: content.lowercased())
    let startLetters: [[Unicode.Scalar?]] = [["l", "a"], ["e", "r"]]
    let player = RandomPlayer(vocabulary: radix)
    let game = Begriffix(startLetters: startLetters, starter: player, opponent: player)!
    measure {
      _ = game.map {$0.1.word}
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
