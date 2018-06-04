final class Node {
  let letter: Character?
  let level: Int
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
  func find(prefix: String) -> Node? {
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
  func find(word: String) -> Node? {
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
  func search(_ prefix: String = "", range: CountableClosedRange<Int>) -> ContiguousArray<String> {
    var subtrieWords = ContiguousArray<String>()
    for (key, child) in children {
      var previousLetters = prefix
      previousLetters.append(key)
      if child.isWord && child.level >= range.lowerBound {
        subtrieWords.append(previousLetters)
      }
      if child.level < range.upperBound && !child.isLeaf {
        subtrieWords += child.search(previousLetters, range: range)
      }
    }
    return subtrieWords
  }
  func match(_ prefix: String = "", pattern: String) -> [String] {
    var subtrieWords = [String]()
    guard level < pattern.count, let char = pattern.prefix(level+1).last else {
      return subtrieWords
    }
    switch char {
    case "?":
      for (key, child) in children {
        var previousLetters = prefix
        previousLetters.append(key)
        if child.isWord && child.level == pattern.count {
          subtrieWords.append(previousLetters)
        }
        subtrieWords += child.match(previousLetters, pattern: pattern)
      }
    default:
      if let child = children[char] {
        var previousLetters = prefix
        previousLetters.append(char)
        if child.isWord && child.level == pattern.count {
          subtrieWords.append(previousLetters)
        }
        subtrieWords += child.match(previousLetters, pattern: pattern)
      }
    }
    /*
     for child in children.values {
     subtrieWords += child.search(previousLetters)
     }
     */
    return subtrieWords
  }
}
