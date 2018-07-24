/// A position in a matrix
public struct Position: Equatable, Hashable, LosslessStringConvertible, ExpressibleByArrayLiteral {
  /// The matrix indices for row (i) and column (j)
  let i: Int, j: Int
  /// Create a position with given indices
  public init(_ i: Int, _ j: Int) {
    self.i = i
    self.j = j
  }
  /// A textual representation as i:j
  public var description: String {
    return "\(i):\(j)"
  }
  /// Initialize a position from a description
  public init?(_ description: String) {
    let values = description.split(separator: ":")
    guard values.count == 2, let i = Int(values[0]), let j = Int(values[1]) else {return nil}
    self.i = i
    self.j = j
  }
  /// Initialize a position from an array literal with 2 elements
  public init(arrayLiteral: Int...) {
    if arrayLiteral.count == 2 {
      self.i = arrayLiteral[0]
      self.j = arrayLiteral[1]
    } else {
      self.i = 0
      self.j = 0
    }
  }
}
