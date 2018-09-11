import Utility

/// The direction on a game board
public enum Direction: String, CaseIterable&Codable {
  /// From left to right
  case Horizontal = "h"
  /// from top to bottom
  case Vertical = "v"
  /// Return a kernel according to this direction and a given length
  func kernel(_ count: Int) -> Matrix<Int> {
    switch self {
    case .Horizontal: return Matrix(repeating: 1, rows: 1, columns: count)
    case .Vertical: return Matrix(repeating: 1, rows: count, columns: 1)
    }
  }
}

/// A place where a word could be written
public struct Place: Hashable&Codable {
  /// The position of the first letter
  public let start: Point
  /// The writing direction
  public let direction: Direction
  /// The word length
  public let count: Int
  /// Initialize a new place
  public init(start: Point, direction: Direction, count: Int) {
    self.start = start
    self.direction = direction
    self.count = count
  }
  /// An area representation of the place for inserting into matrices
  public var area: Area {
    switch direction {
    case .Horizontal:
      return Area(rows: start.row..<(start.row+1), columns: start.column..<(start.column+count))
    case .Vertical:
      return Area(rows: start.row..<(start.row+count), columns: start.column..<(start.column+1))
    }
  }
  /// A matrix filled with 1 according to the area
  var kernel: Matrix<Int> {return direction.kernel(count)}
}
