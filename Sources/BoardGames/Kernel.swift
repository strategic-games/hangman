/// A collection of permuted 1D kernels
struct Kernel {
  enum Direction {
    case Horizontal, Vertical
  }
  /// the full word length
  let count: Int
  let direction: Direction
  let full: Matrix<Int>
  init(count: Int = 2, direction: Direction = .Horizontal) {
    self.count = count
    self.direction = direction
    let size: Dimensions
    switch direction {
    case .Horizontal: size = Dimensions(1, count)
    case .Vertical: size = Dimensions(count, 1)
    }
    full = Matrix(repeating: 1, size: size)
  }
  func permute(around inner: Int) -> [Matrix<Int>] {
  let size: Dimensions
    switch direction {
    case .Horizontal: size = Dimensions(1, count)
    case .Vertical: size = Dimensions(count, 1)
    }
    let permCount = count-inner+1
    var k = [Matrix<Int>]()
    k.reserveCapacity(permCount)
    var a = [Int](repeating: 1, count: inner) + [Int](repeating: 0, count: count-inner)
    repeat {
      k.append(Matrix(a, size: size))
      a.insert(a.removeLast(), at: 0)
    } while k.count < permCount
    return k
  }
  func pattern(_ letters: String, at i: Int) -> String {
    precondition(i+letters.count <= count, "Sum of position and letters count must not exceed word length")
    return String(repeating: "?", count: i) + letters + String(repeating: "?", count: count-i-letters.count)
  }
}

extension Kernel: Equatable, Hashable {
  static func ==(lhs: Kernel, rhs: Kernel) -> Bool {
    return lhs.count == rhs.count && lhs.direction == rhs.direction
  }
}
