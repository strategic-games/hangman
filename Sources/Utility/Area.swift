/// A 2D index range
public struct Area: Hashable {
  /// The row and column ranges
  public let rows: Range<Int>, columns: Range<Int>
  public var indices: (Range<Int>, Range<Int>) {return (rows, columns)}
  /// How many points this would cover
  public var count: Int {return rows.count*columns.count}
  /// The upper left point in this area
  public var start: Point {return Point(row: rows.lowerBound, column: columns.lowerBound)}
  /// The lower right point in this area
  public var end: Point {return Point(row: rows.upperBound-1, column: columns.upperBound-1)}
  /// Initialize a new area
  public init(rows: Range<Int>, columns: Range<Int>) {
    self.rows = rows
    self.columns = columns
  }
  /// Indicates if an area contains the given point
  public func contains(point: Point) -> Bool {
    return rows.contains(point.row) && columns.contains(point.column)
  }
}
