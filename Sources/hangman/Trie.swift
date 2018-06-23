enum Trie {
  typealias T = Character
  typealias Children = [T: Trie]
  indirect case Root(Children, Bool)
  indirect case Node(T, Children, Bool)
  case Leaf(T, Bool)
  init(value: T? = nil, children: Children? = nil, isWord: Bool = false) {
    if let value = value, let children = children {
      self = .Node(value, children, isWord)
    } else if let value = value, children == nil {
      self = .Leaf(value, isWord)
    } else if let children = children, value == nil {
      self = .Root(children, isWord)
    } else {
      self = .Root(Children(), isWord)
    }
  }
  var isWord: Bool {
    get {
      switch self {
      case .Root(_, let isWord): return isWord
      case .Node(_, _, let isWord): return isWord
      case .Leaf(_, let isWord): return isWord
      }
    }
    set {
      switch self {
      case .Root(let children, _): self = .Root(children, newValue)
      case .Node(let letter, let children, _): self = .Node(letter, children, isWord)
      case .Leaf(let letter, _): self = .Leaf(letter, isWord)
      }
    }
  }
  mutating func insert(_ value: String) {
    self = withValue(value, value.startIndex)
  }
  mutating func insert<S>(_ contentsOf: S) where S: Sequence, S.Element == String {
    contentsOf.forEach {insert($0)}
  }
  func contains(_ value: String) -> Bool {
    return contains(value[value.startIndex..<value.endIndex])
  }
  func contains(_ value: Substring) -> Bool {
    guard let char = value.first else {return true}
    let rest = value.dropFirst()
    switch self {
    case .Leaf: return false
    case .Root(let children, _):
      if let child = children[char] {
        return child.contains(rest)
      } else {
        return false
      }
    case .Node(_, let children, let isWord):
      if let child = children[char] {
        return child.contains(rest)
      } else {
        return false
      }
    }
  }
  func find(_ prefix: String = "") -> [String] {
    var words = [String]()
    switch self {
    case .Leaf: return words
    case .Root(let children, let isWord):
      for (key, value) in children {
        var prev = prefix
        prev.append(key)
        if case .Leaf = value {
          words.append(prev)
        }
        words += value.find(prev)
      }
    case .Node(_, let children, let isWord):
      for (key, value) in children {
        var prev = prefix
        prev.append(key)
        if case .Leaf = value {
          words.append(prev)
        }
        words += value.find(prev)
      }
    }
    return words
  }
  private func withValue(_ value: String, _ i: String.Index) -> Trie {
    switch self {
    case .Root(var children, let isWord):
      if i == value.endIndex {
        return .Root(children, true)
      }
      let char = value[i]
      let j = value.index(after: i)
      if let child: Trie = children[char] {
        children[char] = child.withValue(value, j)
      } else {
        children[char] = Trie(value: char).withValue(value, j)
      }
      return .Root(children, isWord)
    case .Node(let letter, var children, let isWord):
      if i == value.endIndex {
        return .Node(letter, children, true)
      }
      let char = value[i]
      let j = value.index(after: i)
      if let child: Trie = children[char] {
        children[char] = child.withValue(value, j)
      } else {
        children[char] = Trie(value: char).withValue(value, j)
      }
      return .Node(letter, children, isWord)
    case .Leaf(let letter, let isWord):
      if i == value.endIndex {
        return .Leaf(letter, true)
      }
      let char = value[i]
      let j = value.index(after: i)
      var children = Children()
      children[char] = Trie(value: char).withValue(value, j)
      return .Node(letter, children, isWord)
    }
  }
}
