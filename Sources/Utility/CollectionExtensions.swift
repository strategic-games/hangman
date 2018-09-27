public extension Collection where Element: Equatable {
  /// Returns the index where a collection diverges from another one
  func index(diverging from: Self) -> Self.Index {
    let shorter = self.count < from.count ? self : from
    var i = shorter.startIndex
    while i < shorter.endIndex {
      if self[i] != from[i] {break}
      shorter.formIndex(after: &i)
    }
    return i
  }
  func match<T: Collection>(pattern: T) -> Bool where T.Element == Element? {
    guard self.count <= pattern.count else {return false}
    return zip(self, pattern).allSatisfy { (x, y) in
      return y == nil ? true : x == y
    }
  }
}

public typealias Pattern = [Unicode.Scalar?]
public extension String {
  var word: [Unicode.Scalar] {return Array(unicodeScalars)}
  init<C: Collection>(word: C) where C.Element == Unicode.Scalar {
    self.init(String.UnicodeScalarView(word))
  }
  var pattern: Pattern {return Array(unicodeScalars.map({$0 == "?" ? nil : $0}))}
  init(pattern: Pattern) {
    self.init(String.UnicodeScalarView(pattern.compactMap({$0 == nil ? "?" : $0})))
  }
}

extension RandomAccessCollection where Element: Equatable {
  /// Returns the indices around a given index to return a slice that is surrounded by a given element
  public func indices(around i: Index, surround: Element) -> Indices {
    assert(indices.contains(i), "i out of bounds")
    var start = i
    var end = i
    for next in indices[..<i].reversed() {
      if self[next] == surround {break}
      start = next
    }
    for next in indices[index(after: i)...] {
      if self[next] == surround {break}
      end = next
    }
    return indices[start...end]
  }
}

public extension RangeReplaceableCollection {
  /// Take a random sample from a range replaceable collection
  func sample(_ size: Int) -> [Element]? {
    guard !isEmpty else {return nil}
    var population = self
    var sample = [Element]()
    sample.reserveCapacity(size)
    repeat {
      guard let i = indices.randomElement() else {return nil}
      sample.append(population.remove(at: i))
    } while sample.count < size
    return sample
  }
}
