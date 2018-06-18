import XCTest
@testable import BoardGames

class BoardGamesTests: XCTestCase {
  var game = Begriffix()
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
  func testExample() {
    game.setup()
    measure {
      game.move((turn: 1, player: 0))
    }
  }
}
