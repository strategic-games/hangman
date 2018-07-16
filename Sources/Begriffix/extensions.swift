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

extension Sequence where Element == Character? {
  func words() -> [String] {
    return self.split(separator: nil).map({w in String(w.compactMap({$0}))}).filter {$0.count > 2}
  }
}
