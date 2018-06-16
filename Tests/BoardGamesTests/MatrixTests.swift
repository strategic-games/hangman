import XCTest
@testable import BoardGames

class MatrixTests: XCTestCase {

  var raw = ""
  var matrix: Matrix<Character?>? = nil
  override func setUp() {
    raw = """
...zh...
...zh...
...zh...
...zh...
"""
    matrix = Matrix<Character?>(raw)
  }

  override func tearDown() {
  }

  func testInitArrays() {
    let rawData = [[Int]](repeating: [Int](repeating: 8, count: 8), count: 8)
    let matrix = Matrix(rawData)
    XCTAssertEqual(matrix.size.count, 64)
  }
  func testInitString() {
    XCTAssertNotNil(matrix)
    raw.append("...")
    XCTAssertNil(Matrix<Character?>(raw))
    XCTAssertEqual(matrix?.size.count, 32)
    XCTAssertEqual(matrix?.size, Dimensions(4, 8))
  }
  func testSubscript() {
    XCTAssertEqual(matrix![Position(3, 3)], "z")
    let row = String(matrix![row: 1].map({$0.symbol}))
    XCTAssertEqual(row, "...zh...")
    let column = String(matrix![column: 3].map({$0.symbol}))
    XCTAssertEqual(column, "zzzz")
    let p = Position(0, 3)
    let s = Dimensions(2)
    let idx: [Int] = matrix!.size.index(p, size: s).joined().map({$0})
    XCTAssertEqual(idx, [3, 4, 11, 12])
    XCTAssertEqual(matrix![11], "z")
    XCTAssertEqual(matrix![12], "h")
    XCTAssertEqual(idx.map({matrix![$0]}), ["z", "h", "z", "h"])
    let partial: [Character?] = matrix![p, s]
    let res: [Character?] = ["z", "h", "z", "h"]
    XCTAssertEqual(partial, res)
  }


}
