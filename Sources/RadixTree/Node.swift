/// A radix tree node
final class Node {
  /// Possible relations between a search string and a node key
  enum PrefixTest {
    /// No common prefix, continue searching
    case empty
    /// key is equal to search
    case keyEqualsSearch
    /// Key contains the search string
    case equalToSearch(keySuffix: Substring)
    /// Key contains a prefix of the search string, continue searching for remaining suffix in the children of this node
    case equalToKey(searchSuffix: Substring)
    /// Key and search string diverge, continue searching
    case partlyEqual(prefix: Substring, keySuffix: Substring, searchSuffix: Substring)
  }
  let key: String
  let level: Int
  var isWord: Bool = false
  private var children = [Node]()
  weak var parent: Node?
  var isLeaf: Bool {
    return children.isEmpty
  }
  init(_ key: String = "", parent: Node? = nil, isWord: Bool = false) {
    self.key = key
    self.parent = parent
    self.isWord = isWord
    let parentLevel = parent?.level ?? 0
    level = parentLevel + 1
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
  func diverge(child: Int, prefix: Substring, suffix: Substring, searchSuffix: Substring) -> Node {
    let oldChild = children[child]
    let newChild = Node(String(prefix), parent: self, isWord: false)
    let x = Node(String(suffix), parent: newChild, isWord: oldChild.isWord)
    x.children = oldChild.children
    let y = Node(String(searchSuffix), parent: newChild, isWord: true)
    newChild.children = [x, y]
    children[child] = newChild
    return newChild
  }
    func split(child: Int, prefix: String, keySuffix: String) -> Node {
        let oldChild = children[child]
        let newChild = Node(prefix, parent: self, isWord: true)
        let x = Node(keySuffix, parent: newChild, isWord: oldChild.isWord)
        x.children = oldChild.children
        newChild.children.append(x)
        children[child] = newChild
        return newChild
    }
  @discardableResult
  func insert(search: String) -> (added: Bool, node: Node) {
    if isLeaf {
        let child = Node(search, parent: self, isWord: true)
      children.append(child)
      return (true, child)
    }
    for (n, child) in children.enumerated() {
      switch child.test(for: search) {
      case .keyEqualsSearch:
        child.isWord = true
        return (false, child)
      case .equalToSearch(let keySuffix):
        let newChild = split(child: n, prefix: String(search), keySuffix: String(keySuffix))
        return (true, newChild)
      case .equalToKey(let suffix):
        return child.insert(search: String(suffix))
      case .partlyEqual(let prefix, let keySuffix, let searchSuffix):
        let newChild = diverge(child: n, prefix: prefix, suffix: keySuffix, searchSuffix: searchSuffix)
        return (true, newChild)
      case .empty: continue
      }
    }
    let child = Node(search, parent: self, isWord: true)
    children.append(child)
    return (true, child)
  }
  func find(prefix: String) -> Node? {
    guard !isLeaf else {return nil}
    for child in children {
        switch child.test(for: prefix) {
      case .keyEqualsSearch: return child
      case .equalToKey(let suffix): return child.find(prefix: String(suffix))
      default: continue
      }
    }
    return nil
  }
  func find(word: String) -> Node? {
    guard !isLeaf else {return nil}
    for child in children {
        switch child.test(for: word) {
        case .keyEqualsSearch: return child.isWord ? child : nil
        case .equalToKey(let suffix): return child.find(word: String(suffix))
        default: continue
        }
    }
    return nil
  }
  func search(_ prefix: String) -> [String] {
  var subtreeWords = [String]()
    for child in children {
      var prev = prefix
      prev += child.key
      if child.isWord {
        subtreeWords.append(prev)
      }
      subtreeWords += child.search(prev)
    }
  return subtreeWords
  }
}

extension Node: Equatable, Hashable {
  static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.key == rhs.key
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(key)
    hasher.combine(isWord)
  }
}
