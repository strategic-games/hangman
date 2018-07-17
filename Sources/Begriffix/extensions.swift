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

extension RandomAccessCollection where Element == Character?, Index == Int {
  func word(around i: Index) -> String? {
    precondition(indices.contains(i), "i out of bounds")
    var start = i
    var end = i
    while start > startIndex {
      let next = index(before: start)
      if self[next] == nil {break}
      start = next
    }
    while end < endIndex {
      formIndex(after: &end)
      if end == endIndex || self[end] == nil {break}
    }
    let r = start..<end
    if r.count <= 2 {return nil}
    let letters = self[r]
    return String(letters.compactMap {$0})
  }
}
