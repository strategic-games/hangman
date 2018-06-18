/// A generic matrix type
struct Matrix<T: Hashable>: Hashable {
  /// The type of the collection which is used internally for the matrix entries
  typealias CollectionType = ContiguousArray<T>
  /// A type which keeps track of matrix dimensions and 1D indices
  typealias Size = Dimensions
  // MARK: Stored properties
  /// The matrix dimensions
  var size: Size
  private var entries: CollectionType
  // MARK: Create matrices
  /// Create matrix from nested arrays
  /// - precondition: Inner arrays must have same length
  init(_ entries: [[T]]) {
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
  init(repeating: T, size: Size) {
    self.size = size
    entries = CollectionType(repeating: repeating, count: size.count)
  }
  /// Create matrix from simple array and given size
  /// - precondition: Array and size must have same count
  init(_ entries: [T], size: Size) {
    precondition(entries.count == size.count, "expected exactly m*n entries")
    self.size = size
    self.entries = CollectionType(entries)
  }
}

// MARK: Adopt protocols
extension Matrix: MutableCollection, RandomAccessCollection {
  /// The collection index type
  typealias Index = CollectionType.Index
  /// The type of collection elements
  typealias Element = CollectionType.Element
  /// The first 1D index
  var startIndex: Index {return entries.startIndex}
  /// The last 1D index
  var endIndex: Index {return entries.endIndex}
  /// Access a matrix element at a given 1D index
  subscript(index: Index) -> Element {
    get {return entries[index]}
    set {entries[index] = newValue}
  }
  /// Return the 1D index after a given 1D index
  func index(after i: Index) -> Index {return entries.index(after: i)}
  /// Return the 1D index before a given 1D index
  func index(before i: Index) -> Index {return entries.index(before: i)}
}

// MARK: Matrix subscripts
extension Matrix {
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
  subscript(row i: Int) -> Slice<Matrix<T>> {
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
  subscript(column j: Int) -> [T] {
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
  subscript(_ start: Position, _ size: Size) -> [Slice<Matrix<T>>] {
    get {
      let idx = self.size.index(start, size: size)
      return idx.map({self[$0]})
    }
  }
  /// Return a matrix slice with given size and start position as array
  subscript(_ start: Position, _ size: Size) -> [T] {
    get {
      let idx = self.size.index(start, size: size).joined()
    return idx.map {self[$0]}
    }
    set {
      let idx = self.size.index(start, size: size).joined().enumerated()
      idx.forEach {(offset, element) in self[element] = newValue[offset]}
    }
  }
  /// Return a matrix slice with given size and start position as matrix
  subscript(_ start: Position, _ size: Size) -> Matrix {
    get {
      let idx = self.size.index(start, size: size).joined()
      return Matrix(idx.map {self[$0]}, size: size)
    }
    set {
      let idx = self.size.index(start, size: size).joined().enumerated()
      idx.forEach {(offset, element) in self[element] = newValue[offset]}
    }
  }
  func map2<T>(_ transform: (Element) -> T) -> Matrix<T> {
    let items = self.map(transform)
    return Matrix<T>(items, size: self.size)
  }
}

// MARK: Number specific stuff
extension Matrix where T: Numeric {
  /// 2D convolution with numeric elements
  /// - params:
  ///   - extend: if true, return matrix with same size as original
  func conv2(_ kernel: Matrix, extend: Bool = false) -> Matrix {
    var result = Matrix(repeating: 0, size: size-kernel.size+1)
    result.size.enumerate { start in
      let idx = size.index(start, size: kernel.size)
      let slices = idx.map({self[$0]}).joined()
      result[start] = zip(slices, kernel).map(*).sum()
    }
    if extend == false {return result}
    let kernSum = kernel.sum()
    var extended = Matrix(repeating: 0, size: size)
    for (offset, element) in result.enumerated() {
      if element != kernSum {continue}
      let start = result.size.position(offset)
      extended[start, kernel.size] = kernel
    }
    return extended
  }
}

extension Sequence where Element: Numeric {
  /// Return the sum of all elements in a numeric sequence
  func sum() -> Element {
    return self.reduce(0, +)
  }
}

// MARK: Text input and output for matrices containing game entities
extension Matrix: CustomStringConvertible, LosslessStringConvertible where T: Entity {
  /// A textual description of a game board
  var description: String {
    var result: String = ""
    result.reserveCapacity(size.count+size.m)
    for i in 0..<size.m {
      let row = self[row: i].map {$0.symbol}
      result.append(row+"\n")
    }
    return result
  }
  /// Create a game matrix from a string
  init?(_ description: String) {
    let lines = description.split(separator: "\n")
    let counts = lines.map {$0.count}
    let equalCounts = counts.allSatisfy {$0 == counts.last}
    guard equalCounts else {return nil}
    let rows: Int, cols: Int
    rows = counts.count
    cols = counts.first ?? 0
    size = Size(rows, cols)
    entries = CollectionType(lines.joined().map {T(from: $0)})
  }
}
