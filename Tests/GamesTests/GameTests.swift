import Foundation
import XCTest
import Utility
@testable import Games

class BegriffixTests: XCTestCase {
  var game: Begriffix?
  // swiftlint:disable force_try
  override func setUp() {
    let bundle = Bundle(for: BegriffixTests.self)
    guard let url = bundle.url(forResource: "Scrabbledict_german", withExtension: "txt") else {return}
    guard let str = try? String(contentsOf: url) else {return}
    let words = str.lowercased().unicodeScalars
      .split(separator: "\n")
      .drop(while: {$0.first == "#"})
      .map {String($0.prefix(while: {$0 != " "}))}
    let radix = Radix()
    radix.insert(words)
  let startLetters = "laer"
  let player = Player(radix)
  let board = try! BegriffixBoard(startLetters: startLetters)
    game = Begriffix(board: board, players: .init(starter: player.move, opponent: player.move))
  }
  func testPerformance() {
    measure {
      guard var game = self.game else {return}
      _ = game.next()
    }
  }
  func testFindPerformance() {
    measure {
      _ = game?.find()
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
