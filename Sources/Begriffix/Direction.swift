/// The direction on a right-angled grid
public enum Direction: CaseIterable {
  /// From left to right
  case Horizontal
  /// from top to bottom
  case Vertical
  /// Return a kernel according to this direction and a given length
  func kernel(_ count: Int) -> Matrix<Int> {
    let size: Dimensions
    switch self {
    case .Horizontal: size = Dimensions(1, count)
    case .Vertical: size = Dimensions(count, 1)
    }
    return Matrix(repeating: 1, size: size)
  }
  /// The opposite of this direction
  func toggled() -> Direction {
    switch self {
    case .Horizontal: return .Vertical
    case .Vertical: return .Horizontal
    }
  }
  /// Set this direction to its opposite
  mutating func toggle() {
    self = toggled()
  }
}
