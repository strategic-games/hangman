final class Node {
  typealias T = StringProtocol&RangeReplaceableCollection
  let letter: Character?
  let level: Int
  var maxLevel: Int = 0
  var isWord = false
  weak var parent: Node?
  var children = [Character:Node](minimumCapacity: 30)
  var isLeaf: Bool {
    return children.isEmpty
  }
  init(letter: Character? = nil, level: Int = 0, parent: Node? = nil) {
    self.letter = letter
    self.level = level
    self.parent = parent
  }
  
  @discardableResult
  func add(child: Character) -> (added: Bool, node: Node) {
    if let node = children[child] {
      return (false, node)
    } else {
      let node = Node(letter: child, level: level+1, parent: self)
      children[child] = node
      return (true, node)
    }
  }
  @discardableResult
  func prune() -> Node {
    var last = self
    while last.isLeaf && !last.isWord, let parent = last.parent, let letter = last.letter {
      last = parent
      last.children[letter] = nil
    }
    return last
  }
  func find<S>(prefix: S) -> Node? where S: T {
    if isLeaf {
      return nil
    }
    var current = self
    for letter in prefix {
      guard let child = current.children[letter] else {
        return nil
      }
      current = child
    }
    return current
  }
  func find<S>(word: S) -> Node? where S: T {
    guard let node = find(prefix: word) else {
      return nil
    }
    return node.isWord ? node : nil
  }
  
  func search(_ prefix: String) -> [String] {
    var subtrieWords = [String]()
    for (key, child) in children {
      var previousLetters = prefix
      previousLetters.append(key)
      if child.isWord {
        subtrieWords.append(previousLetters)
      }
      subtrieWords += child.search(previousLetters)
    }
    return subtrieWords
  }
  func search(_ prefix: String = "", range: CountableClosedRange<Int>) -> [String] {
    var subtrieWords = [String]()
    guard level < range.upperBound else {
      return subtrieWords
    }
    for (key, child) in children {
      guard range.lowerBound <= child.maxLevel else {
        continue
      }
      var previousLetters = prefix
      previousLetters.append(key)
      if child.isWord && child.level >= range.lowerBound {
        subtrieWords.append(previousLetters)
      }
      subtrieWords += child.search(previousLetters, range: range)
    }
    return subtrieWords
  }
  func match<S: T>(_ prefix: String = "", pattern: S) -> [String] {
    var subtrieWords = [String]()
    guard level < pattern.count, let char = pattern.prefix(level+1).last else {
      return subtrieWords
    }
    switch char {
    case "?":
      for (key, child) in children {
        guard pattern.count <= child.maxLevel else {
          continue
        }
        var previousLetters = prefix
        previousLetters.append(key)
        if child.isWord && child.level == pattern.count {
          subtrieWords.append(previousLetters)
        }
        subtrieWords += child.match(previousLetters, pattern: pattern)
      }
    default:
      if let child = children[char] {
        guard pattern.count <= child.maxLevel else {
          break
        }
        var previousLetters = prefix
        previousLetters.append(char)
        if child.isWord && child.level == pattern.count {
          subtrieWords.append(previousLetters)
        }
        subtrieWords += child.match(previousLetters, pattern: pattern)
      }
    }
    return subtrieWords
  }
}
