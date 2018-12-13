/// A 2D grid for game boards etc.
public struct Matrix<Element> {
  // MARK: Properties
  /// The number of rows and columns
  public let rows: Int, columns: Int
  /// A textual representation
  public var description: String {return String(describing: values)}
  /// The total number of elements
  public var count: Int {return rows * columns}
  /// Indicates if the matrix has equal row and column count
  public var isSquare: Bool {return rows == columns}
  /// Indicates if the matrix has even row and column count
  public var isEven: Bool {return rows % 2 == 0 && columns % 2 == 0}
  /// The elements as rowwise array
  public private(set) var values: [Element]
  // MARK: Initializers
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
  // MARK: Subscripts
  /// Access the element at the given position
  public subscript(row: Int, column: Int) -> Element {
    get {
      precondition(isValid(row: row, column: column))
      return values[index(row: row, column: column)]
    }
    set {
      precondition(isValid(row: row, column: column))
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
      precondition(isValid(rows: rows, columns: columns))
      precondition(rows.count == newValue.rows && columns.count == newValue.columns)
      indices(rows: rows, columns: columns).enumerated().forEach {
        self.values[$0.1] = newValue.row($0.0)
      }
    }
  }
  /// Access the elements in the given ranges
  public subscript(rows: Range<Int>, columns: Range<Int>) -> [ArraySlice<Element>] {
    get {
      precondition(isValid(rows: rows, columns: columns), "ranges out of bound")
      return indices(rows: rows, columns: columns).map {values[$0]}
    }
    set {
      precondition(isValid(rows: rows, columns: columns))
      precondition(rows.count == newValue.count && columns.count == newValue[0].count)
      indices(rows: rows, columns: columns).enumerated().forEach {
        self.values[$0.1] = newValue[$0.0]
      }
    }
  }
  /// Access the elements in the given ranges
  public subscript(rows: Range<Int>, columns: Range<Int>) -> [Element] {
    return Array(self[rows, columns].joined())
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
  public func row(_ index: Int) -> ArraySlice<Element> {
  precondition((0..<rows).contains(index))
    let start = columns*index
  let end = columns*(index+1)
  return values[start..<end]
  }
  /// Returns the elements in the given column
  public func column(_ index: Int) -> [Element] {
    precondition((0..<columns).contains(index))
    return stride(from: index, to: values.count, by: columns).map {values[$0]}
  }
  /// Get the elements row by row
  public func rowwise(in indices: Range<Int>? = nil) -> [[Element]] {
    let indices = indices ?? (0..<rows)
    return indices.map {Array(row($0))}
  }
  /// Get the elements column by column
  public func colwise(in indices: Range<Int>? = nil) -> [[Element]] {
    let indices = indices ?? (0..<columns)
    return indices.map {column($0)}
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
  public func point(of index: Int) -> Point {
    return Point(
      row: index/columns,
      column: index%columns
    )
  }
  /// Convert 2D ranges to array indices
  func indices(rows: Range<Int>, columns: Range<Int>) -> [Range<Int>] {
    return rows.map {index(row: $0, column: columns.lowerBound)..<index(row: $0, column: columns.upperBound)}
  }
  /// Indicate if a matrix contains the given coordinates
  public func isValid(row: Int, column: Int) -> Bool {
    return (0..<rows).contains(row) && (0..<columns).contains(column)
  }
  public func isValid(point: Point) -> Bool {
    return isValid(row: point.row, column: point.column)
  }
  /// Indicate if a matrix contains the given 2D range
  public func isValid(rows: Range<Int>, columns: Range<Int>) -> Bool {
    return rows.lowerBound >= 0 && rows.upperBound <= self.rows &&
      columns.lowerBound >= 0 && columns.upperBound <= self.columns
  }
  public func isValid(area: Area) -> Bool {
    return isValid(rows: area.rows, columns: area.columns)
  }
  /// Returns a matrix containing the results of mapping the given closure over the matrix’s elements.
  public func map<T>(_ transform: (Element) -> T) -> Matrix<T> {
    return Matrix<T>(values: values.map(transform), rows: rows, columns: columns)
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
