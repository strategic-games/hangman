/// A radix tree root node
class Node {
  private var children = [Child]()
  weak var parent: Node?
  /// Does this node have any child nodes?
  var isLeaf: Bool {
    return children.isEmpty
  }
  init(_ parent: Node? = nil) {
    self.parent = parent
  }
  func append(_ edge: Child) {
    edge.parent = self
    children.append(edge)
  }
  func diverge(child: Int, prefix: Substring, suffix: Substring, searchSuffix: Substring) -> Child {
    let oldChild = children[child]
    let newChild = Child(String(prefix), parent: self, isWord: false)
    let x = Child(String(suffix), parent: newChild, isWord: oldChild.isWord)
    x.children = oldChild.children
    let y = Child(String(searchSuffix), parent: newChild, isWord: true)
    newChild.children = [x, y]
    children[child] = newChild
    return newChild
  }
    func split(child: Int, prefix: String, keySuffix: String) -> Child {
        let oldChild = children[child]
        let newChild = Child(prefix, parent: self, isWord: true)
        let x = Child(keySuffix, parent: newChild, isWord: oldChild.isWord)
        x.children = oldChild.children
        newChild.children.append(x)
        children[child] = newChild
        return newChild
    }
  @discardableResult
  func insert(search: String) -> (added: Bool, edge: Child) {
    if isLeaf {
        let child = Child(search, parent: self, isWord: true)
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
    let child = Child(search, parent: self, isWord: true)
    children.append(child)
    return (true, child)
  }
  func find(prefix: String) -> Child? {
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
  func find(word: String) -> Child? {
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

