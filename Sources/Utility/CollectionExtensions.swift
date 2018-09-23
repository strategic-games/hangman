extension Collection where Element: Equatable {
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
}

extension BidirectionalCollection where Element: Equatable {
  /// Returns the indices around a given index to return a slice that is surrounded by a given element
  public func indices(around i: Index, surround: Element) -> Range<Index> {
    assert(indices.contains(i), "i out of bounds")
    var start = i
    var end = i
    while start > startIndex {
      let next = index(before: start)
      if self[next] == surround {break}
      start = next
    }
    while end < endIndex {
      formIndex(after: &end)
      if end == endIndex || self[end] == surround {break}
    }
    return start..<end
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
