extension String {
  /// Possible degrees of divergence
  enum Divergence {
    /// No common prefix
    case full
    /// strings are completely equal
    case none
    /// The right string is a prefix of the left
    case left(suffix: Substring)
    /// The left string is a prefix of the right
    case right(suffix: Substring)
    /// Left and right string have a common prefix
    case partly(prefix: Substring, leftSuffix: Substring, rightSuffix: Substring)
  }
  /// Return the degree of divergence of two given strings
  static func %(left: String, right: String) -> Divergence {
    let (prefix, ls, rs) = left/right
    if prefix.isEmpty {return .full}
    if rs.isEmpty && ls.isEmpty {return .none}
    if ls.isEmpty {return .right(suffix: rs)}
    if rs.isEmpty {return .left(suffix: ls)}
    return .partly(prefix: prefix, leftSuffix: ls, rightSuffix: rs)
  }
  /// Return the common prefix of two strings and their diverging suffixes
  static func /(left: String, right: String) -> (Substring, Substring, Substring) {
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
  func matches(_ pattern: String) -> Bool {
    if pattern.count < self.count {return false}
    return zip(self, pattern).allSatisfy {(x: Character, p: Character) in p == "?" ? true : (x == p)}
  }
}
