class Edge: Root {
  /// Possible relations between a search string and a node key
  enum PrefixTest {
    /// No common prefix, continue searching
    case empty
    /// Key contains the search string, found
    case equalToSearch(Substring, Substring, Substring)
    /// Key contains a prefix of the search string, continue searching for remaining suffix in the children of this node
    case equalToKey(Substring, Substring, Substring)
    /// Key and search string diverge, continue searching
    case notEqualToKey(Substring, Substring, Substring)
  }
  let key: String
  var isWord: Bool = false
  var level: Int {
    var i = 0
    for _ in sequence(first: parent, next: {(node: Root?) -> Root? in node?.parent}) {
      i += 1
    }
    return i
  }
  init(_ key: String, _ parent: Root? = nil, _ isWord: Bool = false) {
    self.key = key
    self.isWord = isWord
    super.init(parent)
  }
  /// Test relation between key and a search term
  func test(for search: String) -> PrefixTest {
    let (p, ks, os) = key.branch(with: search)
    if p.isEmpty {return .empty}
    if p == search {return .equalToSearch(p, ks, os)}
    if p == key {return .equalToKey(p, ks, os)}
    return .notEqualToKey(p, ks, os)
  }
}

extension Edge: Equatable, Hashable {
  static func ==(lhs: Edge, rhs: Edge) -> Bool {
    return lhs.key == rhs.key
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(key)
    hasher.combine(isWord)
  }
}

