extension Sequence where Element: Numeric {
  /// Return the sum of all elements in a numeric sequence
  func sum() -> Element {
    return self.reduce(0, +)
  }
  static func *(lhs: Self, rhs: Self) -> [Self.Element] {
    return zip(lhs, rhs).map(*)
  }
  static func prodSum(lhs: Self, rhs: Self) -> Self.Element {
    return zip(lhs, rhs).map(*).sum()
  }
}
