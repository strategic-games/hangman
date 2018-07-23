/// A position in a matrix
public struct Position: Equatable, Hashable {
  /// The matrix indices for row (i) and column (j)
  let i: Int, j: Int
  /// Create a position with given indices
  public init(_ i: Int, _ j: Int) {
    self.i = i
    self.j = j
  }
}
