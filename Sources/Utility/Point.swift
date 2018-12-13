/// A 2D index
public struct Point: Hashable {
  /// The coordinates, starting from zero
  public let row: Int, column: Int
  /// Initialize a new point
  public init(row: Int, column: Int) {
    precondition(row >= 0 && column >= 0, "negative values are not allowed")
    self.row = row
    self.column = column
  }
}

extension Point: LosslessStringConvertible {
  /// A textual description of a point in "row;column" format
  public var description: String {
    return "(\(row),\(column))"
  }
  /// Initialize a point from a stirng which is formatted as "row;column"
  public init?(_ description: String) {
    guard description.hasPrefix("("), description.hasSuffix(")") else {return nil}
    let values = description
      .dropFirst()
      .dropLast()
      .split(separator: ",").compactMap {Int($0)}
    guard values.count == 2 else {return nil}
    self.init(row: values[0], column: values[1])
  }
}

extension Point: Codable {}
