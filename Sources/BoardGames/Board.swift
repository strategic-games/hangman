/// A 2D array
struct Board<Element: Entity&Equatable> {
  private var elements: [[Element]]
  /// The number of rows in this matrix
  var height: Int {
    return elements.count
  }
  /// The number of columns in this matrix
  var width: Int {
    return elements.first?.count ?? 0
  }
  /// The number of cells in this matrix
  var count: Int {
    return height*width
  }
  /// Create a matrix from a 2D array
  init(_ elements: [[Element]]) {
    self.elements = elements
  }
  /// Create a matrix with given dimensions, filled with an initial value
  init(_ initial: Element, width: Int, height: Int) {
    elements = [[Element]](repeating: [Element](repeating: initial, count: width), count: height)
  }
  /// Create a matrix with given dimensions, filled with an initial value
  init(_ initial: Element, sideLength: Int) {
    elements = [[Element]](repeating: [Element](repeating: initial, count: sideLength), count: sideLength)
  }
  /// Return an element by its cell indices
  /// - parameters:
  ///   - i: The row index
  ///   - j: The column index
  /// - returns: a matrix element
  subscript(_ i: Int, _ j: Int) -> Element {
    get {return elements[i][j]}
    set(newValue) {elements[i][j] = newValue}
  }
  /// Return a partial matrix by its cell ranges
  /// - parameters:
  ///   - i: A range of row indices
  ///   - j: A range of column indices
  /// - returns: A matrix slice
  subscript(_ i: Range<Int>, _ j: Range<Int>) -> [ArraySlice<Element>] {
    get {
      return elements[i].map({$0[j]})
    }
    set(newValue) {
      for r in i {
        elements[r][j] = newValue[r]
      }
    }
  }
}

extension Board {
  /// Perform a 2D convolution with a given kernel shape
  func conv2(_ kernel: Board<Bool>) -> Board<Bool> {
    var result = Board<Bool>(false, width: self.width-kernel.width+1, height: self.height-kernel.height+1)
    for i in 0..<result.height {for j in 0..<result.width {
      let partial = self[i..<i+kernel.height, j..<j+kernel.width]
      result[i, j] = zip(partial.joined(), kernel.elements.joined()).allSatisfy({$0.isFilled == $1})
      }}
    return result
  }
}

extension Board: CustomStringConvertible {
  /// A textual description of the matrix
  var description: String {
    var result: String = ""
    for row in elements {
      for cell in row {
        result.append(cell.symbol)
      }
      result.append("\n")
    }
    return result
  }
}

extension Board: LosslessStringConvertible {
  /// Create a matrix from a textual description
  init?(_ description: String) {
    let rows = description.split(separator: "\n")
    let counts: Set<Int> = Set(rows.map({$0.count}))
    guard counts.count == 1 else {return nil}
    elements = rows.map({$0.map({Element(from: $0)})})
  }
}

extension Board: Equatable {
  static func ==(lhs: Board, rhs: Board) -> Bool {
    return lhs.elements == rhs.elements
  }
}
