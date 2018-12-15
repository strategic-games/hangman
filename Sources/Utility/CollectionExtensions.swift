public extension Collection where Element: Equatable {
  /// Returns the index where a collection diverges from another one
  func index(diverging from: Self) -> Self.Index {
    let shorter = self.count < from.count ? self : from
    var index = shorter.startIndex
    while index < shorter.endIndex {
      if self[index] != from[index] {break}
      shorter.formIndex(after: &index)
    }
    return index
  }
  func match<T: Collection>(pattern: T) -> Bool where T.Element == Element? {
    guard self.count <= pattern.count else {return false}
    return zip(self, pattern).allSatisfy {
      if $0.1 == nil {return true}
      return $0.0 == $0.1
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

public extension RangeReplaceableCollection {
  /// Take a random sample from a range replaceable collection
  func sample(_ size: Int) -> [Element]? {
    guard !isEmpty else {return nil}
    var population = self
    var sample = [Element]()
    sample.reserveCapacity(size)
    repeat {
      guard let index = indices.randomElement() else {return nil}
      sample.append(population.remove(at: index))
    } while sample.count < size
    return sample
  }
}

extension Collection {
  /// Split a collection into equal-sized arrays
  ///
  /// If the collection's size is not a multiple of the given size, the last chunk holds the remaining elements.
  ///
  /// - Parameter size: The size of the chunks which the collection is split into.
  /// - Returns: An array of equal-sized chunks
  public func chunked(into size: Int) -> [[Element]] {
    var ranges = [Range<Index>]()
    var end = startIndex
    while end < endIndex {
      let start = end
      _ = formIndex(&end, offsetBy: size, limitedBy: endIndex)
      ranges.append(start..<end)
    }
    return ranges
      .map {Array(self[$0])}
  }
}
