import XCTest
@testable import Begriffix

class GameTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
      let game = Game()
      for (state, move) in game {
        print(state.board)
        print(state.turn)
        print(move.sum)
      }
    }
  func testColision() {
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
  }

}
