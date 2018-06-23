/// A radix tree root node
class Root {
  private var children = [Edge]()
  weak var parent: Root?
  /// Does this node have any child nodes?
  var isLeaf: Bool {
    return children.isEmpty
  }
  init(_ parent: Root? = nil) {
    self.parent = parent
  }
  func append(_ edge: Edge) {
    edge.parent = self
    children.append(edge)
  }
  func diverge(child: Int, prefix: Substring, suffix: Substring, searchSuffix: Substring) -> Edge {
    let oldChild = children[child]
    let newChild = Edge(String(prefix), self, false)
    let x = Edge(String(suffix), newChild, oldChild.isWord)
    x.children = oldChild.children
    let y = Edge(String(searchSuffix), newChild, true)
    newChild.children = [x, y]
    children[child] = newChild
    return newChild
  }
  @discardableResult
  func insert(search: String) -> (added: Bool, edge: Edge) {
    if isLeaf {
      let child = Edge(search, self, true)
      children.append(child)
      return (true, child)
    }
    for (n, child) in children.enumerated() {
      /*
      if child.key == search || child.key.starts(with: search) {return (false, child)}
      let (prefix, suffix, searchSuffix) = child.key.branch(with: search)
      if prefix.isEmpty {continue}
      if search.starts(with: child.key) {
        return child.insert(search: String(searchSuffix))
      }
      if prefix != child.key {
        let newChild = diverge(child: n, prefix: prefix, suffix: suffix, searchSuffix: searchSuffix)
        return (true, newChild)
      }
 */
      switch child.test(for: search) {
      case .equalToSearch:
        child.isWord = true
        return (false, child)
      case .equalToKey(_, _, let suffix):
        return child.insert(search: String(suffix))
      case .notEqualToKey(let prefix, let suffix, let searchSuffix):
        let newChild = diverge(child: n, prefix: prefix, suffix: suffix, searchSuffix: searchSuffix)
        return (true, newChild)
      case .empty: continue
      }
    }
    let child = Edge(search, self, true)
    children.append(child)
    return (true, child)
  }
  func find(prefix: String) -> Edge? {
    guard !isLeaf else {return nil}
    for child in children {
      switch child.test(for: prefix) {
      case .equalToSearch: return child
      case .equalToKey(_, _, let suffix): return child.find(prefix: String(suffix))
      default: continue
      }
    }
    return nil
  }
  func find(word: String) -> Edge? {
    guard let node = find(prefix: word) else {return nil}
    return node.isWord ? node : nil
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

