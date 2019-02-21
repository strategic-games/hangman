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
  func testRestrictedMinWordLength() {
    guard var game = self.game else {return}
    guard let move = game.players.starter(game) else {return}
    XCTAssertEqual(move.hits?.count, 40)
    try! game.insert(move)
    guard let move2 = game.players.opponent(game) else {return}
    XCTAssertEqual(game.moves.count, 1)
    XCTAssertEqual(move2.hits?.count, 20)
    XCTAssertNotEqual(move.place.direction, move2.place.direction)
    try! game.insert(move2)
    XCTAssertEqual(game.find().count, 26)
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
