  /// Possible degrees of divergence
  enum Divergence<T: Collection> {
    /// No common prefix
    case full
    /// strings are completely equal
    case none
    /// The right string is a prefix of the left
    case left(suffix: T.SubSequence)
    /// The left string is a prefix of the right
    case right(suffix: T.SubSequence)
    /// Left and right string have a common prefix
    case partly(prefix: T.SubSequence, leftSuffix: T.SubSequence, rightSuffix: T.SubSequence)
  }
  extension Collection where Element: Equatable {
  /// Return the degree of divergence of two given strings
  static func %(left: Self, right: Self) -> Divergence<Self> {
    let (prefix, ls, rs) = left/right
    if prefix.isEmpty {return .full}
    if rs.isEmpty && ls.isEmpty {return .none}
    if ls.isEmpty {return .right(suffix: rs)}
    if rs.isEmpty {return .left(suffix: ls)}
    return .partly(prefix: prefix, leftSuffix: ls, rightSuffix: rs)
  }
  /// Return the common prefix of two strings and their diverging suffixes
  static func /(left: Self, right: Self) -> (SubSequence, SubSequence, SubSequence) {
    let shorter = left.count < right.count ? left : right
    var i = shorter.startIndex
    while i < shorter.endIndex {
      if left[i] != right[i] {break}
      left.formIndex(after: &i)
    }
    let prefix = left[..<i]
    let leftSuffix = left[i...]
    let rightSuffix = right[i...]
    return (prefix, leftSuffix, rightSuffix)
  }
  /// Indicate if the string matches a given pattern
}

  extension Collection where Element: ExpressibleByUnicodeScalarLiteral&Equatable {
    func matches(_ pattern: Self) -> Bool {
      if pattern.count < self.count {return false}
      return zip(self, pattern).allSatisfy {(x: Element, p: Element) in p == "?" ? true : (x == p)}
    }
  }

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

  extension Sequence where Element == Unicode.Scalar {
    /// Create a string from a sequence of unicode scalars
    var string: String {
      return String.UnicodeScalarView(self).description
    }
  }
