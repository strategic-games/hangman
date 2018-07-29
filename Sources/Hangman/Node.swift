/// A radix tree node
public final class Node: CustomStringConvertible, Equatable, Hashable, Comparable, Codable {
  public typealias Label = [Unicode.Scalar]
  /// The type of the child nodes collection
  public typealias ChildrenType = SortedSet<Node>
  // MARK: Comparison Operators
  /// Test equality of two nodes, respecting only the label
  public static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.label.elementsEqual(rhs.label)
  }
  /// Test order of two nodes, respecting only the label
  public static func <(lhs: Node, rhs: Node) -> Bool {
    return lhs.label.lexicographicallyPrecedes(rhs.label)
  }
  // MARK: Properties
  /// The prefix of this node
  public let label: Label
  /// The tree depth of this node
  public let level: Int
  /// Indicates if this node contains the suffix of an inserted string
  public private(set) var isTerminal: Bool = false
  /// A collection that contains the node's child nodes
  private var children: ChildrenType
  // MARK: Describing
  ///////////// Indicates if the node contains any child nodes
  public var isLeaf: Bool {return children.isEmpty}
  public var isRoot: Bool {return level == 0}
  /// A textual representation of the node
  public var description: String {return "\(level): \(label.string)"}
  /// Hash this node, respecting only its label
  public func hash(into hasher: inout Hasher) {
    hasher.combine(label.map {$0})
  }
  // MARK: Initializers
  /// Create a node
  public init(label: Label = [], level: Int = 0, isTerminal: Bool = false, children: ChildrenType = ChildrenType()) {
    self.label = label
    self.level = level
    self.isTerminal = isTerminal
    self.children = children
  }
  /// Insert a new string into this node
  @discardableResult
  public func insert(_ key: Label) -> (added: Bool, node: Node) {
    if children.isEmpty {return (true, add(key))}
    if let max = children.last, children.count > 3 {
      let i = max.label.index(diverging: key)
      if i == max.label.startIndex && max.label.lexicographicallyPrecedes(key) {return (true, add(key))}
    }
    for child in children {
      let i = child.label.index(diverging: key)
      if i == child.label.startIndex {
        if key.lexicographicallyPrecedes(child.label) {
          break
          } else {
          continue
          }
      } else if i == child.label.endIndex && i == key.endIndex {
        child.isTerminal = true
        return (false, child)
      } else if i == child.label.endIndex {
        return child.insert(Label(key[i...]))
      } else if i == key.endIndex {
        //let newChild = child.split(prefix: key, keySuffix: Label(child.label[i...]))
        let newChild = child.split(at: i)
        children.remove(child)
        children.insert(newChild)
        return (true, newChild)
      } else {
        //let newChild = child.diverge(prefix: Label(child.label[..<i]), keySuffix: Label(child.label[i...]), searchSuffix: Label(key[i...]))
        let newChild = child.diverge(newMember: key, at: i)
        children.remove(child)
        children.insert(newChild)
        return (true, newChild)
      }
    }
    return (true, add(key))
  }
  /// Remove a string from this node if present, and prune leaf nodes if present
  public func remove(_ key: Label) {
    if children.isEmpty {return}
    guard let child = startNode(of: key) else {return}
    if child.label.elementsEqual(key) {
      child.isTerminal = false
    } else {
      child.remove(Label(key[child.label.endIndex...]))
    }
    if !child.isTerminal && child.children.isEmpty {
      children.remove(child)
    }
  }
  // MARK: Testing for membership
  public func contains(_ member: Label) -> Bool {
    return endNode(member) != nil
  }
  // MARK: Searching, filtering
  /// Return an array with every inserted string in this node, the given prefix prepended
  func search(prefix: Label = []) -> [Label] {
  var words = [Label]()
    var prev: Label
    for child in children {
      prev = prefix + child.label
      if child.isTerminal {
        words.append(prev)
      }
      words += child.search(prefix: prev)
    }
  return words
  }
  /// Return an array with every inserted string in this node that match the given pattern, the given prefix prepended
  func search(prefix: Label = [], pattern: [Label.Element?]) -> [Label] {
    var words = [Label]()
    var prev: Label
    for child in children {
      prev = prefix + child.label
      let matches = zip(prev, pattern)
        .allSatisfy {(x, p) in
          if let p = p {
            return x == p
          } else {
            return true
          }
      }
      guard matches else {continue}
      if prev.count == pattern.count && child.isTerminal {
        words.append(prev)
      } else if prev.count < pattern.count {
        words += child.search(prefix: prev, pattern: pattern)
      }
    }
    return words
  }
  // MARK: Finding tree nodes
  /// Return the node which marks the end of a given string if present
  func endNode(_ member: Label) -> Node? {
    if children.isEmpty {return nil}
    guard let child = startNode(of: member) else {return nil}
    if child.label.elementsEqual(member) && child.isTerminal {return child}
    return child.endNode(Label(member[child.label.endIndex...]))
  }
  /// Return the child node whose label is the prefix of or equal to the given string if present
  private func startNode(of member: Label, range: Range<ChildrenType.Index>? = nil) -> Node? {
    let range = range ?? children.startIndex..<children.endIndex
    let mid = range.count/2 + range.lowerBound
    let child = children[mid]
    if member.starts(with: child.label) {return child}
    let left = range[..<mid]
    let right = range[children.index(after: mid)...]
    let selected = child.label.lexicographicallyPrecedes(member) ? right : left
    if selected.isEmpty {return nil}
    return startNode(of: member, range: selected)
  }
  // MARK: Adding and pruning tree nodes
  /// Adds a terminal child node with given label
  @discardableResult
  private func add(_ label: Label) -> Node {
    let child = Node(label: label, level: level+1, isTerminal: true)
    children.insert(child)
    return child
  }
  /// Extract a suffix into a new child node and mark this as terminal
  private func split(at i: Label.Index) -> Node {
    let prefix = Label(label[..<i])
    let suffix = Label(label[i...])
    let newChild = Node(label: prefix, level: self.level, isTerminal: true)
    let x = Node(label: suffix, level: newChild.level+1, isTerminal: self.isTerminal)
    x.children = self.children
    newChild.children.insert(x)
    return newChild
  }
  /// Extract a suffix into a new child node and add another suffix as child node
  private func diverge(newMember: Label, at i: Label.Index) -> Node {
    let prefix = Label(label[..<i])
    let labelSuffix = Label(label[i...])
    let newSuffix = Label(newMember[i...])
    let newChild = Node(label: prefix, level: self.level, isTerminal: false)
    let x = Node(label: labelSuffix, level: newChild.level+1, isTerminal: self.isTerminal)
    x.children = self.children
    let y = Node(label: newSuffix, level: newChild.level+1, isTerminal: true)
    newChild.children.insert(x)
    newChild.children.insert(y)
    return newChild
  }
  // MARK: Encoding and decoding
  /// The coding keys for serialization
  enum CodingKeys: String, CodingKey {
    /// The key for the label property
    case label
    /// The key for the level property
    case level
    /// The key for the isTerminal property
    case isTerminal
    /// The key for the children property
    case children
  }
  /// Initialize a node from a decoder
  public convenience init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let labelString: String = try values.decode(String.self, forKey: .label)
    let label = Label(labelString.unicodeScalars)
    let level = try values.decode(Int.self, forKey: .level)
    let isTerminal = try values.decode(Bool.self, forKey: .isTerminal)
    let children = try values.decode(SortedSet<Node>.self, forKey: .children)
    self.init(label: label, level: level, isTerminal: isTerminal, children: children)
  }
  /// Encode the node into an encoder
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(label.string, forKey: .label)
    try container.encode(level, forKey: .level)
    try container.encode(isTerminal, forKey: .isTerminal)
    try container.encode(children, forKey: .children)
  }
}

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
