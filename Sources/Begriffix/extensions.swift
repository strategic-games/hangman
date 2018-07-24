extension Sequence where Element: Numeric {
  /// Return the sum of all elements in a numeric sequence
  public func sum() -> Element {
    return self.reduce(0, +)
  }
  /// Multiply two sequences elementwise
  static func *(lhs: Self, rhs: Self) -> [Self.Element] {
    return zip(lhs, rhs).map(*)
  }
  /// Multiply two sequences elementwise and sum up the products
  static func prodSum(lhs: Self, rhs: Self) -> Self.Element {
    return zip(lhs, rhs).map(*).sum()
  }
}

extension Sequence where Element == Character? {
  /// Find the words in a sequence (at least 3 letters), separated by nil
  func words() -> [String] {
    return self.split(separator: nil).map({w in String(w.compactMap({$0}))}).filter {$0.count > 2}
  }
}

extension RandomAccessCollection where Element == Character?, Index == Int {
  /// Find the word in a sequence around a given index (nil if less than 3 letters)
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
