/// The size of a 2D grid
struct Dimensions: Hashable, Equatable {
  /// The number of rows (m) and columns (n) in the matrix
  let m: Int, n: Int
  /// The number of elements in a grid with this size
  var count: Int {
    return m*n
  }
  /// Create dimensions with given extends
  init(_ m: Int, _ n: Int) {
    self.m = m
    self.n = n
  }
  /// Create a size for a square shaped grid with a given sidelength
  init(_ sideLength: Int) {
    m = sideLength
    n = sideLength
  }
  /// Indicates if the given position is in the matrix bounds
  func contains(_ position: Position) -> Bool {
    return m > position.i && n > position.j
  }
  /// Return the 1D index corresponding to a grid position
  func index(_ position: Position) -> Int {
    return n*position.i + position.j
  }
  /// Return the 1D indices of a given row index
  func index(row i: Int) -> Range<Int> {
    let r = i*n
    return r..<r+n
  }
  /// Return the 1D indices of a given column index
  func index(column j: Int) -> StrideTo<Int> {
    return stride(from: j, to: m*n+j, by: n)
  }
  /// Return the corresponding 1D indices of a partial grid with a given size
  /// - parameter start: The position, where the upper left corner of the partial grid should be located
  /// - parameter size: The size of the partial grid
  /// - returns: An array of range expressions. Each of them represents a row in the partial grid and can be subscripted from a 1D array.
  func index(_ start: Position, size: Dimensions) -> [Range<Int>] {
    let i = index(start)
    let s = stride(from: i, to: i+size.m*n, by: n)
    return s.map({$0..<$0+size.n})
  }
  /// Return a 2D grid position corresponding to a 1D index
  func position(_ i: Int) -> Position {
    return Position(i/n, i%n)
  }
  /// Loop through all row and column indices and execute a closure with the positions
  func enumerate(_ closure: (_ p: Position) -> Void) {
    for i in 0..<m {
      for j in 0..<n {
        closure(Position(i, j))
      }
    }
  }
}

extension Dimensions: Comparable {
  /// Indicates if a grid size fits into another grid size
  /// At least one dimension of lhs must be smaller than that of rhs
  static func < (lhs: Dimensions, rhs: Dimensions) -> Bool {
    if lhs == rhs {return false}
    return lhs.m > rhs.m || lhs.n > rhs.n ? false : true
  }
}

extension Dimensions {
  /// Add two dimensions
  static func +(lhs: Dimensions, rhs: Dimensions) -> Dimensions {
    return Dimensions(lhs.m+rhs.m, lhs.n+rhs.n)
  }
  /// Subtract a dimension from another
  static func -(lhs: Dimensions, rhs: Dimensions) -> Dimensions {
    return Dimensions(lhs.m-rhs.m, lhs.n-rhs.n)
  }
  /// Add a dimension and a scalar
  static func +(lhs: Dimensions, rhs: Int) -> Dimensions {
    return Dimensions(lhs.m+rhs, lhs.n+rhs)
  }
}

