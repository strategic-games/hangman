/// A collection of unique elements which keeps itself sorted
struct SortedSet<Element: Comparable>: Equatable, ExpressibleByArrayLiteral {
  /// The type of the wrapped collection which holds the elements
  typealias CollectionType = [Element]
  /// A wrapped collection which holds the elements
  fileprivate var items = CollectionType()
  // MARK: Creating sorted sets
  /// create an empty sorted set
  init() {}
  /// Create a sorted set from an already sorted collection of type CollectionType
  fileprivate init(sorted: CollectionType) {
    items = sorted
  }
  /// Create a sorted set from an already sorted sequence
  fileprivate init<S>(sorted: S) where S: Sequence, S.Element == Element {
    items = CollectionType(sorted)
  }
  /// Create a sorted set from an array literal, sorting its content
  init(arrayLiteral: Element...) {
    self.init(arrayLiteral.sorted())
  }
}

// MARK: Describing a sorted set
extension SortedSet: CustomStringConvertible, CustomDebugStringConvertible {
  /// A textual description of the SortedSet
  var description: String {return items.description}
  /// A textual description of the SortedSet (for debugging)
  var debugDescription: String {return items.debugDescription}
}
extension SortedSet: Hashable where Element: Hashable {}

extension SortedSet: RandomAccessCollection {
  // MARK: Manipulating indices
  typealias Index = CollectionType.Index
  typealias SubSequence = CollectionType.SubSequence
  /// The position of the first element in the SortedSet
  var startIndex: Index {return items.startIndex}
  /// The position after the last element in the SortedSet
  var endIndex: Index {return items.endIndex}
  /// The position after the given index
  func index(after i: Index) -> Index {return items.index(after: i)}
  /// The position before the given index
  func index(before i: Index) -> Index {return items.index(before: i)}
  // MARK: Accessing elements
  /// Accesses the element at the given position
  subscript(position: Index) -> Element {return items[position]}
  /// Accesses a contiguous subrange of the array’s elements
  subscript(bounds: Range<Index>) -> SubSequence {return items[bounds]}
  // MARK: Inspecting SortedSets
  var isEmpty: Bool {return items.isEmpty}
}

extension SortedSet: SetAlgebra {
  // MARK: Finding elements
  /// Return the index of the given element using binary search
  func index(of member: Element) -> (found: Bool, index: Index) {
    if items.isEmpty {return (false, items.endIndex)}
    return index(of: member, range: items.startIndex..<items.endIndex)
  }
  private func index(of member: Element, range: Range<Index>) -> (found: Bool, index: Index) {
    let mid = range.count/2 + range.lowerBound
    let item = items[mid]
    if item == member {return (true, mid)}
    let left = range[..<mid]
    let right = range[items.index(after: mid)...]
    let selected = member > item ? right : left
    if selected.isEmpty {return (false, selected.upperBound)}
    return index(of: member, range: selected)
  }
  /// Indicate if the given element is contained in the sorted set
  func contains(_ member: Element) -> Bool {
    return self.index(of: member).found
  }
  /// Return the minimum element in the sorted set, its first element
  func min() -> Element? {return items.first}
  /// Return the maximum element in the sorted set, its last element
  func max() -> Element? {return items.last}
  // MARK: Adding elements
  /// Insert an element into the sorted set if not already present
  @discardableResult
  mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
    let (found, i) = self.index(of: newMember)
    if found == false {
      items.insert(newMember, at: i)
      return (true, newMember)
    } else {
      return (false, items[i])
    }
  }
  /// Insert an element inconditionally
  @discardableResult
  mutating func update(with newMember: Element) -> Element? {
    let (found, i) = self.index(of: newMember)
    if found == false {
      items.insert(newMember, at: i)
      return nil
    } else {
      items[i] = newMember
      return newMember
    }
  }
  // MARK: Removing elements
  /// Remove an element from a sorted set
  @discardableResult
  mutating func remove(_ member: Element) -> Element? {
    let (found, i) = index(of: member)
    if found == false {
      return nil
    } else {
      return items.remove(at: i)
    }
  }
  /// Remove the element at a given position
  @discardableResult
  mutating func remove(at position: Index) -> Element? {
    return items.remove(at: position)
  }
  /// Return a sorted set containing the elements of this set that satisfy the given predicate
  func filter(_ predicate: (Element) -> Bool) -> SortedSet<Element> {
    return SortedSet(sorted: items.filter(predicate))
  }
  // MARK: Combining sorted sets
  /// Return a new sorted set containing the elements of this and another set
  func union(_ other: SortedSet<Element>) -> SortedSet<Element> {
    var new = CollectionType()
    let a = self.items, b = other.items
    var i = a.startIndex, j = b.startIndex
    while i < a.endIndex, j < b.endIndex {
      let x = a[i], y = b[j]
      if x < y {
        new.append(x)
        a.formIndex(after: &i)
      } else if y < x {
        new.append(y)
        b.formIndex(after: &j)
      } else {
        new.append(x)
        a.formIndex(after: &i)
        b.formIndex(after: &j)
      }
    }
    if i < a.endIndex {new += a[i...]}
    if j < b.endIndex {new += b[j...]}
    return SortedSet(sorted: new)
  }
  /// Add the elements of the given sorted set
  mutating func formUnion(_ other: SortedSet<Element>) {
    self = union(other)
  }
  /// Return a new set containing the elements that are common to this and the given set
  func intersection(_ other: SortedSet<Element>) -> SortedSet<Element> {
    var new = CollectionType()
    let a = self.items, b = other.items
    var i = a.startIndex, j = b.startIndex
    while i < a.endIndex, j < b.endIndex {
      let x = a[i], y = b[j]
      if x < y {
        a.formIndex(after: &i)
      } else if y < x {
        b.formIndex(after: &j)
      } else {
        new.append(x)
        a.formIndex(after: &i)
        b.formIndex(after: &j)
      }
    }
    return SortedSet(sorted: new)
  }
  /// Removes the elements of this set that aren’t also in the given set
  mutating func formIntersection(_ other: SortedSet<Element>) {
    self = intersection(other)
  }
  /// Return a new set with the elements that are either in this or in the given set, but not in both
  func symmetricDifference(_ other: SortedSet<Element>) -> SortedSet<Element> {
    var new = CollectionType()
    let a = self.items, b = other.items
    var i = a.startIndex, j = b.startIndex
    while i < a.endIndex, j < b.endIndex {
      let x = a[i], y = b[j]
      if x < y {
        new.append(x)
        a.formIndex(after: &i)
      } else if y < x {
        new.append(y)
        b.formIndex(after: &j)
      } else {
        a.formIndex(after: &i)
        b.formIndex(after: &j)
      }
      if i < a.endIndex {new += a[i...]}
      if j < b.endIndex {new += b[j...]}
    }
    return SortedSet(sorted: new)
  }
  /// Removes the elements of the set that are also in the given set and adds the members of the given set that are not already in the set
  mutating func formSymmetricDifference(_ other: SortedSet<Element>) {
    self = symmetricDifference(other)
  }
}

// MARK: Encoding and decoding
extension SortedSet: Codable where Element: Codable {
  /// Creates a sorted set by decoding from the given decoder
  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    var items = CollectionType()
    while !container.isAtEnd {
      let item = try container.decode(Element.self)
      items.append(item)
    }
    self.items = items
  }
  /// Encode a sorted set into the given encoder
  func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in self {
      try container.encode(element)
    }
  }
}
