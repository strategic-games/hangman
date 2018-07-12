import XCTest
@testable import Begriffix

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
  func testConv2() {
    let nums: Matrix<Int> = Matrix(matrix!.map({$0 != nil ? 1 : 0}), size: matrix!.size)
    let kernel = Matrix<Int>(repeating: 1, size: Dimensions(2))
    XCTAssertEqual(kernel.size.m, 2)
    XCTAssertEqual(kernel.sum(), 4)
    let res = nums.conv2(kernel)
    let ext = nums.conv2(kernel).extend(kernel)
    XCTAssertEqual(res.size, Dimensions(3, 7))
    XCTAssertEqual(ext.size, Dimensions(4, 8))
  }
  func testDilate() {
    let kh = Matrix(repeating: 1, size: Dimensions(1, 2))
    let mh = Matrix([1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1], size: Dimensions(3, 6))
    let rh = Matrix([1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1], size: Dimensions(3, 6))
    XCTAssertEqual(mh.conv2(kh).dilate(kh), rh)
    let kv = Matrix(repeating: 1, size: Dimensions(2, 1))
    let mv = Matrix([1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1], size: Dimensions(6, 3))
    let rv = Matrix([1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1], size: Dimensions(6, 3))
    XCTAssertEqual(mv.conv2(kv).dilate(kv), rv)
  }
  func testCharacter() {
    let startLetters = Matrix<Character?>([["z", "h"], ["e", "n"]])
    var board = Matrix<Character?>(repeating: nil, size: Dimensions(8, 8))
    board[Position(3, 3), Dimensions(2, 2)] = startLetters
    let start = Position(3, 0)
    let dir = Direction.Horizontal
    let count: Int = 8
    board[start, dir, count] = [Character]("herzhaft")
    board[Position(0, 3), .Vertical, 7] = [Character]("reizend")
    print(board)
  }
}
