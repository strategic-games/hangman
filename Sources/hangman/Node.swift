/// A radix tree node
public final class Node {
  /// The type of the child nodes collection
  public typealias ChildrenType = SortedSet<Node>
  /// The prefix of this node
  public let label: String
  /// The tree depth of this node
  public let level: Int
  /// Indicates if this node contains the suffix of an inserted string
  public var isTerminal: Bool = false
  /// A collection that contains the node's child nodes
  private var children: ChildrenType
  ///////////// Indicates if the node contains any child nodes
  public var isLeaf: Bool {
    return children.isEmpty
  }
  // MARK: Initializers
  /// Create a node
  public init(label: String, level: Int, isTerminal: Bool, children: ChildrenType) {
    self.label = label
    self.level = level
    self.isTerminal = isTerminal
    self.children = children
  }
  /// Create a leaf node
  public convenience init(_ label: String, level: Int, isTerminal: Bool) {
    self.init(label: label, level: level, isTerminal: isTerminal, children: ChildrenType())
  }
  /// Create a non-terminal leaf node
  public convenience init(_ label: String, level: Int) {
    self.init(label: label, level: level, isTerminal: false, children: ChildrenType())
  }
  /// Create a root node
  public convenience init() {
    self.init(label: "", level: 0, isTerminal: false, children: ChildrenType())
  }
  /// Add a child node with given prefix
  public func add(prefix: String) -> Node {
    let child = Node(prefix, level: level+1, isTerminal: true)
    children.insert(child)
    return child
  }
  /// Extract a suffix into a new child node and mark this as terminal
  func split(prefix: String, keySuffix: String) -> Node {
    let newChild = Node(prefix, level: self.level, isTerminal: true)
    let x = Node(keySuffix, level: newChild.level+1, isTerminal: self.isTerminal)
    x.children = self.children
    newChild.children.insert(x)
    return newChild
  }
  /// Extract a suffix into a new child node and add another suffix as child node
  func diverge(prefix: String, keySuffix: String, searchSuffix: String) -> Node {
    let newChild = Node(prefix, level: self.level, isTerminal: false)
    let x = Node(keySuffix, level: newChild.level+1, isTerminal: self.isTerminal)
    x.children = self.children
    let y = Node(searchSuffix, level: newChild.level+1, isTerminal: true)
    newChild.children.formUnion([x, y])
    return newChild
  }
  /// Insert a new string into this node
  @discardableResult
  public func insert(_ key: String) -> (added: Bool, node: Node) {
    guard !children.isEmpty else {return (true, add(prefix: key))}
    if children.count > 3, let max = children.last {
      let (prefix, _, _) = max.label/key
      if prefix.isEmpty && max.label < key {return (true, add(prefix: key))}
    }
    for child in children {
      switch child.label%key {
      case .none:
        child.isTerminal = true
        return (false, child)
      case .left(let leftSuffix):
        let newChild = child.split(prefix: key, keySuffix: String(leftSuffix))
        children.remove(child)
        children.insert(newChild)
        return (true, newChild)
      case .right(let rightSuffix):
        return child.insert(String(rightSuffix))
      case .partly(let prefix, let leftSuffix, let rightSuffix):
        let newChild = child.diverge(prefix: String(prefix), keySuffix: String(leftSuffix), searchSuffix: String(rightSuffix))
        children.remove(child)
        children.insert(newChild)
        return (true, newChild)
      case .full:
        if child.label > key {
          break
        } else {
          continue
        }
      }
    }
    return (true, add(prefix: key))
  }
  /// Remove a string from this node if present, and prune leaf nodes if present
  public func remove(_ key: String) {
    guard !children.isEmpty else {return}
    guard let child = index(of: key) else {return}
    if child.label == key {
      child.isTerminal = false
    } else {
      child.remove(String(key[child.label.endIndex...]))
    }
    if !child.isTerminal && child.children.isEmpty {
      children.remove(child)
    }
  }
  /// Return the node which marks the end of a given string if present
  func find(_ key: String) -> Node? {
    guard !children.isEmpty else {return nil}
    guard let child = index(of: key) else {return nil}
    if child.label == key && child.isTerminal {return child}
    return child.find(String(key[child.label.endIndex...]))
  }
  /// Return an array with every inserted string in this node, the given prefix prepended
  func search(_ prefix: String) -> [String] {
  var subtreeWords = [String]()
    for child in children {
      var prev = prefix
      prev += child.label
      if child.isTerminal {
        subtreeWords.append(prev)
      }
      subtreeWords += child.search(prev)
    }
  return subtreeWords
  }
  /// Return an array with every inserted string in this node that match the given pattern, the given prefix prepended
  func match(_ prefix: String, pattern: String) -> [String] {
    var subtreeWords = [String]()
    for child in children {
      var prev = prefix
      prev += child.label
      guard prev.matches(pattern) else {continue}
      if prev.count == pattern.count && child.isTerminal {
        subtreeWords.append(prev)
      }
      subtreeWords += child.match(prev, pattern: pattern)
    }
    return subtreeWords
  }
  /// Return the child node whose label is the prefix of or equal to the given string if present
  private func index(of prefix: String) -> Node? {
    return index(of: prefix, range: children.startIndex..<children.endIndex)
  }
  private func index(of prefix: String, range: Range<ChildrenType.Index>) -> Node? {
    let mid = range.count/2 + range.lowerBound
    let child = children[mid]
    if prefix.hasPrefix(child.label) {return child}
    let left = range[..<mid]
    let right = range[children.index(after: mid)...]
    let selected = prefix > child.label ? right : left
    if selected.isEmpty {return nil}
    return index(of: prefix, range: selected)
  }
}

extension Node: Equatable, Hashable, Comparable {
  /// Test equality of two nodes, respecting only the label
  public static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.label == rhs.label
  }
  /// Test order of two nodes, respecting only the label
  public static func <(lhs: Node, rhs: Node) -> Bool {
    return lhs.label < rhs.label
  }
  /// Hash this node, respecting only its label
  public func hash(into hasher: inout Hasher) {
    hasher.combine(label)
  }
}

extension Node: Codable {
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
    let label = try values.decode(String.self, forKey: .label)
    let level = try values.decode(Int.self, forKey: .level)
    let isTerminal = try values.decode(Bool.self, forKey: .isTerminal)
    let children = try values.decode(SortedSet<Node>.self, forKey: .children)
    self.init(label: label, level: level, isTerminal: isTerminal, children: children)
  }
  /// Encode the node into an encoder
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(label, forKey: .label)
    try container.encode(level, forKey: .level)
    try container.encode(isTerminal, forKey: .isTerminal)
    try container.encode(children, forKey: .children)
  }
}

extension Node: CustomStringConvertible {
  /// A textual representation of the node
  public var description: String {
    return "\(level): \(label)"
  }
}
