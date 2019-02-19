import XCTest
@testable import Utility
@testable import Games

// swiftlint:disable force_try
class BegriffixBoardTests: XCTestCase {
  // MARK: Initializers
  func testNonSquareFails() {
    let fields = Matrix<Unicode.Scalar?>(repeating: nil, rows: 6, columns: 4)
    XCTAssertThrowsError(try BegriffixBoard(fields: fields))
  }
  func testOddSquareFails() {
    for size in stride(from: 5, through: 11, by: 2) {
      let fields = Matrix<Unicode.Scalar?>(repeating: nil, rows: size, columns: size)
      XCTAssertThrowsError(try BegriffixBoard(fields: fields))
    }
  }
  func testEvenSquareSucceeds() {
    for size in stride(from: 6, through: 12, by: 2) {
      let fields = Matrix<Unicode.Scalar?>(repeating: nil, rows: size, columns: size)
      XCTAssertNoThrow(try BegriffixBoard(fields: fields))
    }
  }
  func testOddSidelengthFails() {
    for size in stride(from: 5, through: 11, by: 2) {
      XCTAssertThrowsError(try BegriffixBoard(startLetters: "xxxx", sideLength: size))
    }
  }
  func testEvenSidelengthSucceeds() {
    for size in stride(from: 6, through: 12, by: 2) {
      XCTAssertNoThrow(try BegriffixBoard(startLetters: "xxxx", sideLength: size))
    }
  }
  func testWrongLetterCountFails() {
    XCTAssertNoThrow(try BegriffixBoard(startLetters: "xxxx"))
      XCTAssertThrowsError(try BegriffixBoard(startLetters: "xxxxx"))
  }
  func testUnequalRowsFail() {
    XCTAssertNotNil(try BegriffixBoard(startLetters: [["x", "x"], ["x", "x"]]))
    XCTAssertNil(try BegriffixBoard(startLetters: [["x", "x"], ["x", "x", "x"]]))
  }
  // MARK: Inserting
  func testInsertingMismatchFails() {
    var board = try! BegriffixBoard(startLetters: "xxxx")
    let word: [Unicode.Scalar] = Array("yyyyyy".unicodeScalars)
    let place = Place(start: .init(row: 3, column: 0), direction: .horizontal, count: 6)
    XCTAssertThrowsError(try board.insert(word, at: place))
  }
  func testInsertingMatchSucceeds() {
    var board = try! BegriffixBoard(startLetters: "xxxx")
    let word: [Unicode.Scalar] = Array("xxxxxx".unicodeScalars)
    let place = Place(start: .init(row: 3, column: 0), direction: .horizontal, count: 6)
    XCTAssertNoThrow(try board.insert(word, at: place))
  }
  func testPlaceOutOfBoundFails() {
    var board = try! BegriffixBoard(startLetters: "xxxx")
    let word: [Unicode.Scalar] = Array("xxxxxx".unicodeScalars)
    let place = Place(start: .init(row: 3, column: 4), direction: .horizontal, count: 6)
    XCTAssertThrowsError(try board.insert(word, at: place))
  }
  func testFindsOnlyValidPlaces() {
    let board = try! BegriffixBoard(startLetters: "xxxx")
    var places = [Place]()
    for dir in Direction.allCases {
      for count in 4...8 {
        places += board.find(direction: dir, count: count)
      }
    }
    places.forEach {
      XCTAssert(board.isValid($0))
    }
  }
  func testWordInLine() {
    let pattern: BegriffixBoard.Pattern = [nil, "x", "y", "z", nil]
    let word: Begriffix.Word = ["x", "y", "z"]
    XCTAssertEqual(BegriffixBoard.word(in: pattern, around: 2), word)
  }
  // MARK: findBalance
  func testBalanceafterFirstHorizontalMoveIsVertical() {
    var board = try! BegriffixBoard(startLetters: "xxxx")
    let point = Point(row: 3, column: 3)
    let word = "xxxxx"
    let place = Place(start: point, direction: .horizontal, count: 5)
    try! board.insert(Array(word.unicodeScalars), at: place)
    let balance = board.findBalance()
    XCTAssertEqual(balance, .vertical)
  }
  func testBalanceAfterInit() {
    let board = try! BegriffixBoard(startLetters: "xxxx")
    XCTAssertNil(board.findBalance())
  }
  func testBalanceafterFirstVerticalMoveIsHorizontal() {
    var board = try! BegriffixBoard(startLetters: "xxxx")
    let point = Point(row: 3, column: 3)
    let word = "xxxxx"
    let place = Place(start: point, direction: .vertical, count: 5)
    try! board.insert(Array(word.unicodeScalars), at: place)
    let balance = board.findBalance()
    XCTAssertEqual(balance, .horizontal)
  }
}
