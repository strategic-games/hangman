/// A generic matrix type
public struct Matrix<Element>: MutableCollection, RandomAccessCollection {
  /// The type of the collection which is used internally for the matrix entries
  public typealias CollectionType = [Element]
  /// A type which keeps track of matrix dimensions and 1D indices
  typealias Size = Dimensions
  // MARK: Stored properties
  /// The matrix dimensions
  var size: Size
  private var entries: CollectionType
  // MARK: Initializers
  /// Create matrix from nested arrays
  /// - precondition: Inner arrays must have same length
  init(_ entries: [[Element]]) {
    let counts = entries.map {$0.count}
    let equalCounts = counts.allSatisfy {$0 == counts.last}
    precondition(equalCounts, "expected row counts to be equal")
    let rows: Int, cols: Int
    rows = counts.count
    cols = counts.first ?? 0
    size = Size(cols, rows)
    self.entries = CollectionType(entries.joined())
  }
  /// Create matrix with given size and prefill with repeating value
  init(repeating: Element, size: Size) {
    self.size = size
    entries = CollectionType(repeating: repeating, count: size.count)
  }
  /// Create matrix from simple array and given size
  /// - precondition: Array and size must have same count
  init(_ entries: [Element], size: Size) {
    precondition(entries.count == size.count, "expected exactly m*n entries")
    self.size = size
    self.entries = CollectionType(entries)
  }
  // MARK: Indices
  /// The collection index type
  public typealias Index = CollectionType.Index
  /// The first 1D index
  public var startIndex: Index {return entries.startIndex}
  /// The last 1D index
  public var endIndex: Index {return entries.endIndex}
  /// Return the 1D index after a given 1D index
  public func index(after i: Index) -> Index {return entries.index(after: i)}
  /// Return the 1D index before a given 1D index
  public func index(before i: Index) -> Index {return entries.index(before: i)}
  /// Access a matrix element at a given 1D index
  // MARK: Subscripts
  public subscript(index: Index) -> Element {
    get {return entries[index]}
    set {entries[index] = newValue}
  }
  /// Return the matrix element at a given position
  /// - precondition: The position must be in the bounds of the matrix dimensions
  subscript(_ position: Position) -> Element {
    get {
      precondition(size.contains(position), "Out of bounds")
      return self[size.index(position)]
    }
    set {
      precondition(size.contains(position), "Out of bounds")
      self[size.index(position)] = newValue
    }
  }
  /// Return the elements in a given matrix row as slice
  /// - precondition: Row must not exceed dimensions
  subscript(row i: Int) -> Slice<Matrix<Element>> {
    get {
      precondition(i < size.m, "row out of bounds")
      let idx: Range<Int> = size.index(row: i)
      return self[idx]
    }
    set {
      precondition(i < size.m, "row out of bounds")
      let idx: Range<Int> = size.index(row: i)
      self[idx] = newValue
    }
  }
  /// Return the elements at a given column index as array
  /// - precondition: column must not exceed dimensions
  subscript(column j: Int) -> [Element] {
    get {
      precondition(j < size.n, "column out of bounds")
      let idx: StrideTo<Int> = size.index(column: j)
      return idx.map {self[$0]}
    }
    set {
      let idx = size.index(column: j).enumerated()
      idx.forEach {(offset, element) in self[element] = newValue[offset]}
    }
  }
  /// Return a matrix slice with a given size and reference position
  subscript(_ start: Position, _ size: Size) -> [Slice<Matrix<Element>>] {
    let idx = self.size.index(start, size: size)
    return idx.map({self[$0]})
  }
  /// Return a matrix slice with given size and start position as matrix
  subscript(_ start: Position, _ size: Size) -> Matrix<Element> {
    get {
      let idx = self.size.index(start, size: size).joined()
      return Matrix(idx.map {self[$0]}, size: size)
    }
    set {
      let idx = self.size.index(start, size: size).joined().enumerated()
      idx.forEach {(offset, element) in self[element] = newValue[offset]}
    }
  }
  /// Subscript a matrix with given place
  subscript(place: Place) -> [Element] {
    get {
      let idx = size.index(place.start)
      switch place.direction {
      case .Horizontal:
        let idx2 = entries.index(idx, offsetBy: place.count)
        return [Element](entries[idx..<idx2])
      case .Vertical:
        return stride(from: idx, to: place.count*size.n+idx, by: size.n).map {entries[$0]}
      }
    }
    set {
      let idx = size.index(place.start)
      switch place.direction {
      case .Horizontal:
        let idx2 = entries.index(idx, offsetBy: place.count)
        entries.replaceSubrange(idx..<idx2, with: newValue)
      case .Vertical:
        let s = stride(from: idx, to: place.count*size.n+idx, by: size.n)
        zip(s, newValue).forEach {(n, x) in entries[n] = x}
      }
    }
  }
  /// Get the matrix as lines, by the given direction
  func lines(by direction: Direction, in range: Range<Index>? = nil) -> [[Element]] {
    switch direction {
    case .Horizontal:
      let lines = range ?? (0..<size.m)
      return lines.lazy.map {Array(self[row: $0])}
    case .Vertical:
      let lines = range ?? (0..<size.n)
      return lines.lazy.map {Array(self[column: $0])}
    }
  }
  // MARK: Transforming
  /// Transform the matrix element with a given closure and return them as new matrix
  public func map2<T>(_ transform: (Element) -> T) -> Matrix<T> {
    let items = self.map(transform)
    return Matrix<T>(items, size: self.size)
  }
}

// MARK: Number specific stuff
extension Matrix where Element: Numeric {
  /// Elementwise matrix multiplication
  static func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    return Matrix(zip(lhs.entries, rhs.entries).map(*), size: lhs.size)
  }
  /// 2D convolution with numeric elements
  func conv2(_ kernel: Matrix) -> Matrix {
    var result = Matrix(repeating: 0, size: size-kernel.size+1)
    result.size.enumerate { start in
      let idx = size.index(start, size: kernel.size)
      let slices = idx.map({self[$0]}).joined()
      result[start] = zip(slices, kernel).map(*).sum()
    }
    return result
  }
  /// Extend conv2 matrix with a given kernel
  func extend(_ kernel: Matrix) -> Matrix<Element> {
    let kernSum = kernel.sum()
    var extended = Matrix(repeating: 0, size: size+kernel.size-1)
    for (offset, element) in self.enumerated() {
      if element != kernSum {continue}
      let start = self.size.position(offset)
      extended[start, kernel.size] = kernel
    }
    return extended
  }
  /// Extend and dilate conv2 matrix with a given kernel
  func dilate(_ kernel: Matrix) -> Matrix<Element> {
    var dilated = Matrix(repeating: 0, size: size+kernel.size-1)
    for (offset, element) in self.enumerated() {
      if element == 0 {continue}
      let start = self.size.position(offset)
      dilated[start, kernel.size] = kernel
    }
    return dilated
  }
  /// Recode the matrix values by subtracting them from a given maximum value
  func invert(max: Element = 1) -> Matrix<Element> {
    return self.map2 {max - $0}
  }
}

// MARK: Text input and output for matrices containing game entities
extension Matrix: CustomStringConvertible, LosslessStringConvertible where Element == Character? {
  /// A textual description of a game board
  public var description: String {
    var result: String = ""
    result.reserveCapacity(size.count+size.m)
    for i in 0..<size.m {
      let row: [Character] = self[row: i].map({$0 ?? "."})
      result.append(row+"\n")
    }
    return result
  }
  /// Create a game matrix from a string
  public init?(_ description: String) {
    let lines = description.split(separator: "\n")
    let counts = lines.map {$0.count}
    let equalCounts = counts.allSatisfy {$0 == counts.last}
    guard equalCounts else {return nil}
    let rows: Int, cols: Int
    rows = counts.count
    cols = counts.first ?? 0
    size = Size(rows, cols)
    entries = CollectionType(lines.joined().map {$0 == "." ? nil : $0})
  }
}

extension Sequence where Element: Numeric {
  /// Return the sum of all elements in a numeric sequence
  public func sum() -> Element {
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
