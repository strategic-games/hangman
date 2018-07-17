public enum Direction: CaseIterable {
  case Horizontal, Vertical
  func kernel(_ count: Int) -> Matrix<Int> {
    let size: Dimensions
    switch self {
    case .Horizontal: size = Dimensions(1, count)
    case .Vertical: size = Dimensions(count, 1)
    }
    return Matrix(repeating: 1, size: size)
  }
  func toggled() -> Direction {
    switch self {
    case .Horizontal: return .Vertical
    case .Vertical: return .Horizontal
    }
  }
  mutating func toggle() {
    self = toggled()
  }
}
