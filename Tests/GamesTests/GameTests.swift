import XCTest
import Utility
@testable import Games

class BegriffixTests: XCTestCase {
  func testPerformance() {
    let radix = Radix()
    let startLetters = "laer"
    let player = Player(radix)
    // swiftlint:disable force_try
    let board = try! BegriffixBoard(startLetters: startLetters)
    let game = Begriffix(board: board, starter: player.move, opponent: player.move)
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
