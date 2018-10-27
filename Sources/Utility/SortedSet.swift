/// A collection of unique elements which keeps itself sorted
public struct SortedSet<Element: Comparable>: SelfSorting {
  /// The type of the wrapped collection which holds the elements
  public typealias CollectionType = [Element]
  /// A wrapped collection which holds the elements
  fileprivate var items = CollectionType()
  // MARK: Creating sorted sets
  /// create an empty sorted set
  public init() {}
  /// Create a sorted set from an already sorted collection of type CollectionType
  fileprivate init(sorted: CollectionType) {
    items = sorted
  }
  /// Create a sorted set from an already sorted sequence
  fileprivate init<S>(sorted: S) where S: Sequence, S.Element == Element {
    items = CollectionType(sorted)
  }
}

extension SortedSet: ExpressibleByArrayLiteral {
  /// Create a sorted set from an array literal, sorting its content
  public init(arrayLiteral: Element...) {
    self.init(arrayLiteral.sorted())
  }
}

// MARK: Describing a sorted set
extension SortedSet: CustomStringConvertible, CustomDebugStringConvertible {
  /// A textual description of the SortedSet
  public var description: String {return items.description}
  /// A textual description of the SortedSet (for debugging)
  public var debugDescription: String {return items.debugDescription}
}
extension SortedSet: Hashable where Element: Hashable {}

extension SortedSet: RandomAccessCollection {
  // MARK: Manipulating indices
  public typealias Index = CollectionType.Index
  /// The position of the first element in the SortedSet
  public var startIndex: Index {return items.startIndex}
  /// The position after the last element in the SortedSet
  public var endIndex: Index {return items.endIndex}
  // swiftlint:disable identifier_name
  /// The position after the given index
  public func index(after i: Index) -> Index {return items.index(after: i)}
  /// The position before the given index
  public func index(before i: Index) -> Index {return items.index(before: i)}
  // swiftlint:enable identifier_name
  // MARK: Accessing elements
  /// Accesses the element at the given position
  public subscript(position: Index) -> Element {return items[position]}
  /// Accesses a contiguous subrange of the array’s elements
  public subscript(bounds: Range<Index>) -> CollectionType.SubSequence {return items[bounds]}
  // MARK: Inspecting SortedSets
  public var isEmpty: Bool {return items.isEmpty}
}

extension SortedSet: SetAlgebra {
  // MARK: Adding elements
  /// Insert an element into the sorted set if not already present
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
    let (found, index) = firstIndex(of: newMember)
    if found == false {
      items.insert(newMember, at: index)
      return (true, newMember)
    } else {
      return (false, items[index])
    }
  }
  /// Insert an element inconditionally
  @discardableResult
  public mutating func update(with newMember: Element) -> Element? {
    let (found, index) = firstIndex(of: newMember)
    if found == false {
      items.insert(newMember, at: index)
      return nil
    } else {
      items[index] = newMember
      return newMember
    }
  }
  // MARK: Removing elements
  /// Remove an element from a sorted set
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    let (found, index) = firstIndex(of: member)
    if found == false {
      return nil
    } else {
      return items.remove(at: index)
    }
  }
  /// Remove the element at a given position
  @discardableResult
  public mutating func remove(at position: Index) -> Element? {
    return items.remove(at: position)
  }
  /// Return a sorted set containing the elements of this set that satisfy the given predicate
  public func filter(_ predicate: (Element) -> Bool) -> SortedSet<Element> {
    return SortedSet(sorted: items.filter(predicate))
  }
  // MARK: Combining sorted sets
  /// Return a new sorted set containing the elements of this and another set
  public func union(_ other: SortedSet<Element>) -> SortedSet<Element> {
    var new = CollectionType()
    var index = items.startIndex, otherIndex = other.items.startIndex
    while index < items.endIndex, otherIndex < other.items.endIndex {
      let item = items[index], otherItem = other.items[otherIndex]
      if item < otherItem {
        new.append(item)
        items.formIndex(after: &index)
      } else if otherItem < item {
        new.append(otherItem)
        other.items.formIndex(after: &otherIndex)
      } else {
        new.append(item)
        items.formIndex(after: &index)
        other.items.formIndex(after: &otherIndex)
      }
    }
    if index < items.endIndex {new += items[index...]}
    if otherIndex < other.items.endIndex {new += other.items[otherIndex...]}
    return SortedSet(sorted: new)
  }
  /// Add the elements of the given sorted set
  public mutating func formUnion(_ other: SortedSet<Element>) {
    self = union(other)
  }
  /// Return a new set containing the elements that are common to this and the given set
  public func intersection(_ other: SortedSet<Element>) -> SortedSet<Element> {
    var new = CollectionType()
    var index = items.startIndex, otherIndex = other.items.startIndex
    while index < items.endIndex, otherIndex < other.items.endIndex {
      let item = items[index], otherItem = other.items[otherIndex]
      if item < otherItem {
        items.formIndex(after: &index)
      } else if otherItem < item {
        other.items.formIndex(after: &otherIndex)
      } else {
        new.append(item)
        items.formIndex(after: &index)
        other.items.formIndex(after: &otherIndex)
      }
    }
    return SortedSet(sorted: new)
  }
  /// Removes the elements of this set that aren’t also in the given set
  public mutating func formIntersection(_ other: SortedSet<Element>) {
    self = intersection(other)
  }
  /// Return a new set with the elements that are either in this or in the given set, but not in both
  public func symmetricDifference(_ other: SortedSet<Element>) -> SortedSet<Element> {
    var new = CollectionType()
    var index = items.startIndex, otherIndex = other.items.startIndex
    while index < items.endIndex, otherIndex < other.items.endIndex {
      let item = items[index], otherItem = other.items[otherIndex]
      if item < otherItem {
        new.append(item)
        items.formIndex(after: &index)
      } else if otherItem < item {
        new.append(otherItem)
        other.items.formIndex(after: &otherIndex)
      } else {
        items.formIndex(after: &index)
        other.items.formIndex(after: &otherIndex)
      }
      if index < items.endIndex {new += items[index...]}
      if otherIndex < other.items.endIndex {new += other.items[otherIndex...]}
    }
    return SortedSet(sorted: new)
  }
  /// Removes the elements of the set that are also in the given set
  /// and adds the members of the given set that are not already in the set
  public mutating func formSymmetricDifference(_ other: SortedSet<Element>) {
    self = symmetricDifference(other)
  }
}

// MARK: Encoding and decoding
extension SortedSet: Codable where Element: Codable {
  public init(from decoder: Decoder) throws {
    items = CollectionType()
    var container = try decoder.unkeyedContainer()
    while !container.isAtEnd {
      let item = try container.decode(Element.self)
      items.append(item)
    }
  }
  public func encode(to encoder: Encoder) throws {
    try items.encode(to: encoder)
  }
}
