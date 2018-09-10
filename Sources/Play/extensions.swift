import SwiftCLI
import Utility

extension Point: LosslessStringConvertible, ConvertibleFromString {
  /// A textual representation in chess notation
  public var description: String {
    let iLetter: Unicode.Scalar = Unicode.Scalar(row+97) ?? "?"
    return "\(iLetter)\(column+1)"
  }
  /// Initialize a point from chess notation
  public init?(_ description: String) {
    let scalars = description.unicodeScalars.map {Int($0.value)}
    guard scalars.count == 2 else {return nil}
    self.init(row: scalars[0]-97, column: scalars[1]-49)
  }
}

extension Area: LosslessStringConvertible {
  public init(start: Point, end: Point) {
    self.init(rows: Range(start.row...end.row), columns: Range(start.column...end.column))
  }
  /// A textual Excel-like representation
  public var description: String {
    return "\(start):\(end)"
  }
  public init?(_ description: String) {
    let scalars = description.unicodeScalars.map {Int($0.value)}
    let points = scalars.split(separator: 58)
    guard scalars.count == 5 && points.count == 2 else {return nil}
    self.init(start: Point(row: points[0][0]-97, column: points[0][1]-49), end: Point(row: points[1][0]-97, column: points[1][1]-49))
  }
}
