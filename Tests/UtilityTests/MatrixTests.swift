import XCTest
@testable import Utility

class MatrixTests: XCTestCase {
  var raw = ""
  var matrix: Matrix<Character?>?
  override func setUp() {
    raw = """
...zh...
...zh...
...zh...
...zh...
"""
    let values = raw.map({$0 == "." ? nil : $0}).split(separator: "\n").map({Array($0)})
    matrix = Matrix<Character?>(values: values)
  }

  func testInitializeWithNestedArrays() {
    var rawData = [[Int]](repeating: [Int](repeating: 8, count: 8), count: 8)
    let matrix = Matrix(values: rawData)
    XCTAssertNotNil(matrix)
    XCTAssertEqual(matrix?.count, 64)
    rawData.append([Int](repeating: 8, count: 4))
    XCTAssertNil(Matrix(values: rawData))
  }
  func testInitString() {
    XCTAssertNotNil(matrix)
    XCTAssertEqual(matrix?.count, 32)
    XCTAssertEqual(matrix?.rows, 4)
    XCTAssertEqual(matrix?.columns, 8)
  }
  func testConv2() {
    let nums = Matrix(
      values: matrix!.values.map {$0 != nil ? 1 : 0},
      rows: matrix!.rows,
      columns: matrix!.columns
    )
    let kernel = Matrix<Int>(repeating: 1, rows: 2, columns: 2)
    XCTAssertEqual(kernel.rows, 2)
    XCTAssertEqual(kernel.values.sum(), 4)
    let res = nums.conv2(kernel)
    let ext = nums.conv2(kernel).extend(kernel)
    XCTAssertEqual(res.rows, 3)
    XCTAssertEqual(res.columns, 7)
    XCTAssertEqual(ext.rows, 4)
    XCTAssertEqual(ext.columns, 8)
  }
  func testDilateHorizontal() {
    let kern = Matrix(repeating: 1, rows: 1, columns: 2)
    let matrix = Matrix(values: [1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1], rows: 3, columns: 6)
    let result = Matrix(values: [1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1], rows: 3, columns: 6)
    XCTAssert(matrix.conv2(kern).dilate(kern).values.elementsEqual(result.values))
  }
  func testDilateVertical() {
    let kern = Matrix(repeating: 1, rows: 2, columns: 1)
    let matrix = Matrix(values: [1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1], rows: 6, columns: 3)
    let result = Matrix(values: [1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1], rows: 6, columns: 3)
    XCTAssert(matrix.conv2(kern).dilate(kern).values.elementsEqual(result.values))
  }
  func testSubscripts() {
    let startLetters = Matrix<Character?>(values: [["z", "h"], ["e", "n"]])!
    XCTAssertEqual(startLetters.rows, 2)
    XCTAssertEqual(startLetters.columns, 2)
    var board = Matrix<Character?>(repeating: nil, rows: 8, columns: 8)
    board[3..<5, 3..<5] = startLetters
    let area = Area(rows: 3..<4, columns: 0..<8)
    board[area] = Matrix(values: [Character]("herzhaft"), rows: 1, columns: 8)
    let area2 = Area(rows: 0..<7, columns: 3..<4)
    board[area2] = Matrix(values: [Character]("reizend"), rows: 7, columns: 1)
    XCTAssertEqual(board[3, 3], "z")
    XCTAssertEqual(board[3, 0], "h")
    XCTAssertEqual(board[0, 3], "r")
  }
  func testColwise() {
    let values = [1, 2, 3, 4, 5, 6]
    let matrix = Matrix(values: values, rows: 3, columns: 2)
    let columns = [[1, 3, 5], [2, 4, 6]]
    XCTAssertEqual(matrix.colwise(), columns)
  }
}
