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

extension RandomAccessCollection where Element == Character? {
  func word(around i: Index) -> String? {
    var start = i
    var end = i
    while end > startIndex {
      let next = index(before: start)
      if self[next] == nil {break}
      start = next
    }
    while end < endIndex {
      let next = index(after: end)
      if self[next] == nil {break}
      end = next
    }
    let letters = self[start..<end]
    if letters.count <= 2 {return nil}
    return String(letters.compactMap {$0})
  }
}
