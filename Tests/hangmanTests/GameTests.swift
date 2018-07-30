import XCTest
@testable import Hangman

class GameTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

  func testPerformance() {
    let b = Bundle(for: Radix.self)
    guard let url = b.url(forResource: "dictionaries/german", withExtension: "txt") else {return}
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {return}
    let radix = Radix(text: content.lowercased())
    let startLetters: [[Character?]] = [["l", "a"], ["e", "r"]]
    let player = RandomPlayer(vocabulary: radix)
    let game = Begriffix(startLetters: startLetters, starter: player, opponent: player)
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
    guard let board = Matrix(values) else {return}
    let state = State(turn: 4, player: true, board: board)
    var game = Game()
    game.state = state
    guard let (_, move) = game.next() else {return}
  }
  func testLinePerformance() {
    print(Player.radix.contains("hallo"))
    let game = Game()
    measure {
      for (_, _) in game {}
    }
  }
  func testCollectionWord() {
    let x: [Character?] = [nil, "x", "y", "z", nil]
    XCTAssertEqual(x.word(around: 2), "xyz")
  }*/

}
