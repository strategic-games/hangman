/// A radix tree that stores strings
public struct Radix: Codable {
  /// The root node of the tree
  private let root: Node
  /// Create a tree with a given root node
  public init(_ root: Node) {
    self.root = root
  }
  /// Create an empty tree
  public init() {
    self.init(Node())
  }
  /// Insert a string into the tree
  public func insert(_ key: String) {
    root.insert(key)
  }
  /// Insert the elements of a given sequence into the tree
  public func insert<S: Sequence>(_ s: S) where S.Element == String {
    s.forEach {root.insert($0)}
  }
  /// Split a string by whitespace and insert the fragments into the tree
  public func insert(text: String, separator: Character = "\n") {
    text.split(separator: separator)
      .lazy
      .filter {!$0.isEmpty}
      .map {$0.lowercased()}
      .forEach {root.insert($0)}
  }
  /// Remove a given string from this tree if present
  public func remove(_ key: String) {
    root.remove(key)
  }
  /// Indicate if a given string is present in the tree
  public func contains(_ key: String) -> Bool {
    return root.find(key) != nil
  }
  /// Return a new array with the strings in this tree
  public func search() -> [String] {
    return root.search("")
  }
  /// Return a new array with the strings in this tree that satisfy the given pattern
  public func match(_ pattern: String) -> [String] {
    return root.match("", pattern: pattern)
  }
}

extension Radix: CustomStringConvertible {
  /// The textual representation of the root node
  public var description: String {
    return root.description
  }
}
