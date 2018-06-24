class Edge: Root {
  /// Possible relations between a search string and a node key
  enum PrefixTest {
    /// No common prefix, continue searching
    case empty
    /// Key contains the search string
    case equalToSearch(keySuffix: Substring)
    case keyEqualsSearch
    /// Key contains a prefix of the search string, continue searching for remaining suffix in the children of this node
    case equalToKey(searchSuffix: Substring)
    /// Key and search string diverge, continue searching
    case partlyEqual(prefix: Substring, keySuffix: Substring, searchSuffix: Substring)
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
  init(_ key: String, parent: Root? = nil, isWord: Bool = false) {
    self.key = key
    self.isWord = isWord
    super.init(parent)
  }
  /// Test relation between key and a search term
  func test(for search: String) -> PrefixTest {
    let (p, ks, os) = key.branch(with: search)
    if p.isEmpty {return .empty}
    if os.isEmpty && ks.isEmpty {return .keyEqualsSearch}
    if ks.isEmpty {return .equalToKey(searchSuffix: os)}
    if os.isEmpty {return .equalToSearch(keySuffix: ks)}
    return .partlyEqual(prefix: p, keySuffix: ks, searchSuffix: os)
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

