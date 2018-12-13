import XCTest
import Utility
import Games

class StrategyTests: XCTestCase {
  // swiftlint:disable force_try
  let board = try! BegriffixBoard(startLetters: "xxxx")
  let randomPlayer = Player(Radix(), begriffixStrategy: randomBegriffixStrategy)
  let shortPlayer = Player(Radix(), begriffixStrategy: shortBegriffixStrategy)
  let longPlayer = Player(Radix(), begriffixStrategy: longBegriffixStrategy)
  let availabilityPlayer = Player(Radix(), begriffixStrategy: availabilityBegriffixStrategy)
  let hits: [Place: [Begriffix.Word]] = [
    Place(start: Point(row: 3, column: 0), direction: .horizontal, count: 8): [.init(repeating: "x", count: 8)],
    Place(start: Point(row: 3, column: 0), direction: .horizontal, count: 7): [.init(repeating: "x", count: 7)],
    Place(start: Point(row: 3, column: 2), direction: .horizontal, count: 6): [.init(repeating: "x", count: 6)],
    Place(start: Point(row: 3, column: 4), direction: .horizontal, count: 4): [.init(repeating: "x", count: 4)]
  ]
  func testRandom() {
    let game = Begriffix(board: board, starter: randomPlayer.move, opponent: randomPlayer.move)
    let move = randomBegriffixStrategy(hits: hits, game: game)
    XCTAssertNotNil(move)
  }
  func testShort() {
    let game = Begriffix(board: board, starter: shortPlayer.move, opponent: shortPlayer.move)
    let move = shortBegriffixStrategy(hits: hits, game: game)
    XCTAssertEqual(move?.place.count, 4)
  }
  func testLong() {
    let game = Begriffix(board: board, starter: longPlayer.move, opponent: longPlayer.move)
    let move = longBegriffixStrategy(hits: hits, game: game)
    XCTAssertEqual(move?.place.count, 8)
  }
  func testAvailability() {
    let game = Begriffix(board: board, starter: availabilityPlayer.move, opponent: availabilityPlayer.move)
    let move = availabilityBegriffixStrategy(hits: hits, game: game)
    XCTAssertEqual(move?.place.count, 4)
  }
  }
