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
    let ext = nums.conv2(kernel, extend: true)
    XCTAssertEqual(res.size, Dimensions(3, 7))
    XCTAssertEqual(ext.size, Dimensions(4, 8))
  }
}
