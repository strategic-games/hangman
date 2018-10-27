/// A collection that keeps its elements lexicographically sorted
public protocol SelfSorting: RandomAccessCollection where Element: Comparable {}

public extension SelfSorting {
  typealias Predicate = (Element) -> Bool
  /// Return the minimum element in the sorted set, its first element
  func min() -> Element? {return first}
  /// Return the maximum element in the sorted set, its last element
  func max() -> Element? {return last}
  func contains(_ element: Element) -> Bool {
    let (found, _) = firstIndex(of: element)
    return found
  }
  func first(where equals: Predicate, precedes: Predicate) -> Element? {
    let (found, index) = firstIndex(where: equals, precedes: precedes)
    return found ? self[index] : nil
  }
  func firstIndex(of element: Element) -> (Bool, Index) {
    return firstIndex(where: {$0 == element}, precedes: {$0 < element})
    }
  func firstIndex(where equals: Predicate, precedes: Predicate) -> (Bool, Index) {
    var region = indices
    while !region.isEmpty {
      let mid = region.midIndex
      let candidate = self[mid]
      if equals(candidate) {
        return (true, mid)
      } else if precedes(candidate) {
        region = region.upperHalf
      } else {
        region = region.lowerHalf
      }
    }
    return (false, region.endIndex)
  }
}

// MARK: Divide and conquer
public extension Collection {
  /// Returns a slice of the collection containing every elements below and including the middle element
  var lowerHalf: SubSequence {
    return self[..<midIndex]
  }
  /// Returns a slice of the collection containing every elements above the middle element
  var upperHalf: SubSequence {
    return self[index(after: midIndex)...]
  }
  /// The index of the middle element in the collection
  var midIndex: Index {
    return index(startIndex,
                 offsetBy: distance(from: startIndex, to: endIndex) / 2
    )
  }
}
