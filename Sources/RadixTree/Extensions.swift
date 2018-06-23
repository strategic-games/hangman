extension String {
  func branch(with other: String) -> (Substring, Substring, Substring) {
    var i = startIndex
    for (x, y): (Character, Character) in zip(self, other) {
      if x != y {break}
      i = index(after: i)
    }
    let prefix = self[..<i]
    let suffix = self[i...]
    let otherSuffix = other[i...]
    return (prefix, suffix, otherSuffix)
  }
}
