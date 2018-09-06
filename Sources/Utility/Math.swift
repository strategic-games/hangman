public extension Collection where Element: Numeric {
  /// Return the sum of all elements in a numeric sequence
  func sum() -> Element {
    return self.reduce(0, +)
  }
  /// Multiply two sequences elementwise
  static func * (lhs: Self, rhs: Self) -> [Self.Element] {
    return zip(lhs, rhs).map(*)
  }
  /// Multiply two sequences elementwise and sum up the products
  static func prodSum(lhs: Self, rhs: Self) -> Self.Element {
    return zip(lhs, rhs).map(*).sum()
  }
}

public extension Collection where Element == Int {
  /// Returns the arithmetic mean of an int collection
  func mean() -> Int {
    return self.sum()/self.count
  }
}

public extension Collection where Element == Double {
  /// Returns the arithmetic mean of a double collection
  func mean() -> Double {
    return self.sum()/Double(self.count)
  }
}


public extension Matrix where Element: Numeric {
  /// Recode the matrix values by subtracting them from a given maximum value
  func invert(max: Element = 1) -> Matrix<Element> {
    return Matrix(values: values.map({max-$0}), rows: rows, columns: columns)
  }
  /// Elementwise matrix multiplication
  static func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    return Matrix(values: zip(lhs.values, rhs.values).map(*), rows: lhs.rows, columns: lhs.columns)
  }
  /// 2D convolution with numeric elements
  func conv2(_ kernel: Matrix) -> Matrix {
    var result = Matrix(repeating: 0, rows: rows-kernel.rows+1, columns: columns-kernel.columns+1)
    for row in 0..<result.rows {
      for column in 0..<result.columns {
        let slices = self[row..<(row+kernel.rows), column..<(column+kernel.columns)].joined()
        result[row, column] = zip(slices, kernel.values).map(*).sum()
      }
    }
    return result
  }
  /// Extend conv2 matrix with a given kernel
  func extend(_ kernel: Matrix) -> Matrix<Element> {
    let kernSum = kernel.values.sum()
    var extended = Matrix(repeating: 0, rows: rows+kernel.rows-1, columns: columns+kernel.columns-1)
    for (n, x) in values.enumerated() {
      if x != kernSum {continue}
      let p = point(of: n)
      extended[p.row..<(p.row+kernel.rows), p.column..<(p.column+kernel.columns)] = kernel
    }
    return extended
  }
  /// Extend and dilate conv2 matrix with a given kernel
  func dilate(_ kernel: Matrix) -> Matrix<Element> {
    var dilated = Matrix(repeating: 0, rows: rows+kernel.rows-1, columns: columns+kernel.columns-1)
    for (n, x) in values.enumerated() {
      if x == 0 {continue}
      let p = point(of: n)
      dilated[p.row..<(p.row+kernel.rows), p.column..<(p.column+kernel.columns)] = kernel
    }
    return dilated
  }
}
