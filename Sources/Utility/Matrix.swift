/// A 2D index
public struct Point: Hashable {
  /// The coordinates, starting from zero
  public let row: Int, column: Int
  /// Initialize a new point
  public init(row: Int, column: Int) {
    assert(row >= 0 && column >= 0, "negative values are not allowed")
    self.row = row
    self.column = column
  }
}

extension Point: LosslessStringConvertible {
  /// A textual description of a point in "row;column" format
  public var description: String {
    return "\(row);\(column)"
  }
  /// Initialize a point from a stirng which is formatted as "row;column"
  public init?(_ description: String) {
    let values = description.split(separator: ";").compactMap {Int($0)}
    guard values.count == 2 else {return nil}
    self.init(row: values[0], column: values[1])
  }
}

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

/// A 2D grid for game boards etc.
public struct Matrix<Element> {
  //MARK: Properties
  /// The number of rows and columns
  public let rows: Int, columns: Int
  /// A textual representation
  public var description: String {return String(describing: values)}
  /// The total number of elements
  public var count: Int {return rows*columns}
  /// The elements as rowwise array
  public private(set) var values: [Element]
  //MARK: Initializers
  /// Initialize new with values and dimensions
  public init(values: [Element], rows: Int, columns: Int) {
    assert(columns*rows == values.count, "dimensions and values do not match")
    self.rows = rows
    self.columns = columns
    self.values = values
  }
  /// Initialize with values and the dimensions of a given area
  public init(values: [Element], area: Area) {
    self.init(values: values, rows: area.rows.count, columns: area.columns.count)
  }
  /// Initialize with a nested array
  public init?(values: [[Element]]) {
    guard !values.isEmpty else {return nil}
    let counts = values.map {$0.count}
    guard counts.allSatisfy({$0 == counts.last}) else {return nil}
    rows = counts.count
    columns = counts[0]
    self.values = .init(values.joined())
  }
  /// Initialize with a repeated value and dimensions
  public init(repeating: Element, rows: Int, columns: Int) {
    self.rows = rows
    self.columns = columns
    values = .init(repeating: repeating, count: columns*rows)
  }
  /// Initialize with a repeated value and dimensions from a given area
  public init(repeating: Element, area: Area) {
    self.init(repeating: repeating, rows: area.rows.count, columns: area.columns.count)
  }
  //MARK: Subscripts
  /// Access the element at the given position
  public subscript(row: Int, column: Int) -> Element {
    get {
      assert(isValid(row: row, column: column))
      return values[index(row: row, column: column)]
    }
    set {
      assert(isValid(row: row, column: column))
      values[index(row: row, column: column)] = newValue
    }
  }
  /// Access the element at the given point
  public subscript(point: Point) -> Element {
    get {return self[point.row, point.column]}
    set {self[point.row, point.column] = newValue}
  }
  /// Access the elements in the given ranges
  public subscript(rows: Range<Int>, columns: Range<Int>) -> Matrix<Element> {
    get {
      return Matrix(values: Array(self[rows, columns].joined()), rows: rows.count, columns: columns.count)
    }
    set {
      assert(isValid(rows: rows, columns: columns))
      assert(rows.count == newValue.rows && columns.count == newValue.columns)
      indices(rows: rows, columns: columns).enumerated().forEach { (n, x) in
        self.values[x] = newValue.row(n)
      }
    }
  }
  /// Access the elements in the given ranges
  public subscript(rows: Range<Int>, columns: Range<Int>) -> [ArraySlice<Element>] {
    get {
      assert(isValid(rows: rows, columns: columns), "ranges out of bound")
      return indices(rows: rows, columns: columns).map {values[$0]}
    }
    set {
      assert(isValid(rows: rows, columns: columns))
      assert(rows.count == newValue.count && columns.count == newValue[0].count)
      indices(rows: rows, columns: columns).enumerated().forEach { (n, x) in
        self.values[x] = newValue[n]
      }
    }
  }
  /// Access the elements in the given ranges
  public subscript(rows: Range<Int>, columns: Range<Int>) -> [Element] {
    get {return Array(self[rows, columns].joined())}
  }
  /// Access the elements in the given area
  public subscript(area: Area) -> Matrix<Element> {
    get {return self[area.rows, area.columns]}
    set {self[area.rows, area.columns] = newValue}
  }
  /// Access the elements in the given area
  public subscript(area: Area) -> [ArraySlice<Element>] {
    get {return self[area.rows, area.columns]}
    set {self[area.rows, area.columns] = newValue}
  }
  /// Returns the elements in the given row
  public func row(_ i: Int) -> ArraySlice<Element> {
  assert(i >= 0 && i < rows)
    let start = columns*i
  let end = columns*(i+1)
  return values[start..<end]
  }
  /// Returns the elements in the given column
  public func column(_ j: Int) -> [Element] {
    assert(j >= 0 && j < columns)
    return stride(from: j, to: rows*columns+j, by: columns).map {values[$0]}
  }
  /// Get the elements row by row
  public func rowwise(in indices: Range<Int>? = nil) -> [[Element]] {
    let indices = indices ?? (0..<rows)
    return indices.lazy.map {Array(row($0))}
  }
  /// Get the elements column by column
  public func colwise(in indices: Range<Int>? = nil) -> [[Element]] {
    let indices = indices ?? (0..<columns)
    return indices.lazy.map {column($0)}
  }
  /// Convert coordinates to array index
  func index(row: Int, column: Int) -> Int {
    return columns*row + column
  }
  /// Convert point to array index
  public func index(point: Point) -> Int {
    return index(row: point.row, column: point.column)
  }
  /// Convert array index to point
  public func point(of i: Int) -> Point {
    return Point(row: i/columns, column: i%columns)
  }
  /// Convert 2D ranges to array indices
  func indices(rows: Range<Int>, columns: Range<Int>) -> [Range<Int>] {
    return rows.map {index(row: $0, column: columns.lowerBound)..<index(row: $0, column: columns.upperBound)}
  }
  /// Indicate if a matrix contains the given coordinates
  func isValid(row: Int, column: Int) -> Bool {
    return (0..<rows).contains(row) && (0..<columns).contains(column)
  }
  /// Indicate if a matrix contains the given 2D range
  func isValid(rows: Range<Int>, columns: Range<Int>) -> Bool {
    return rows.lowerBound >= 0 && rows.upperBound <= self.rows && columns.lowerBound >= 0 && columns.upperBound <= self.columns
  }
}

extension Matrix: CustomStringConvertible where Element == Character {
  public var description: String {
    var str = String()
    rowwise().forEach { (row: [Character]) in
      row.forEach {str.append($0)}
      str.append("\n")
    }
    return str
  }
}
extension Point: Codable {}

extension Range: Codable where Bound: Codable {
  enum CodingKeys: CodingKey {
    case lower, upper
  }
  public func encode(to encoder: Encoder) throws {
    let dict = [CodingKeys.lower.stringValue: lowerBound, CodingKeys.upper.stringValue: upperBound]
    try dict.encode(to: encoder)
  }
  public init(from decoder: Decoder) throws {
    let dict = try [String: Bound](from: decoder)
    guard let lower = dict[CodingKeys.lower.stringValue] else {
      throw DecodingError.valueNotFound(Bound.self, .init(codingPath: decoder.codingPath + [CodingKeys.lower], debugDescription: "lowerBound not found"))
    }
    guard let upper = dict[CodingKeys.upper.stringValue] else {
      throw DecodingError.valueNotFound(Bound.self, .init(codingPath: decoder.codingPath + [CodingKeys.upper], debugDescription: "upperBound not found"))
    }
    self.init(uncheckedBounds: (lower: lower, upper: upper))
  }
}
