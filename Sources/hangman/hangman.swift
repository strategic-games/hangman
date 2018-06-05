/**
 A trie implementation for word based games
*/
public final class Hangman {
  /**
   The root node of the actual trie structure
  */
  private let root = Node()
  /**
  Create a clean trie
  */
  public init() {}
  /**
  Create a trie from a Sequence of Strings
  */
  public init<Source>(_ sequence: Source) where Source: Sequence, Source.Element == String {
    sequence.forEach({insert($0)})
  }
  /**
  Inserts a word in the trie if not already present
  */
  @discardableResult
  public func insert(_ word: String) -> (inserted: Bool, word: String) {
    var currentNode = root
    if word.count > currentNode.maxLevel {
      currentNode.maxLevel = word.count
    }
    for character in word {
      currentNode = currentNode.add(child: character).node
      if word.count > currentNode.maxLevel {
        currentNode.maxLevel = word.count
      }
    }
    if currentNode.isWord {
      return (false, word)
    }
    currentNode.isWord = true
    return (true, word)
  }
  /**
  Remove a word from the trie if still present
  */
  @discardableResult
  public func remove(_ word: String) -> (removed: Bool, word: String) {
    if word.isEmpty {
      return (false, word)
    }
    guard let node = root.find(word: word) else {
      return (false, word)
    }
    node.isWord = false
    node.prune()
    return (true, word)
  }

  /**
  Check if the trie contains a given word
  */
  public func contains(_ word: String) -> Bool {
    return root.find(word: word) != nil
  }
  public func search(prefix: String) -> [String] {
    guard let node = root.find(prefix: prefix) else {
      return [String]()
    }
    var words = [String]()
    if node.isWord {
      words.append(prefix)
    }
    words += node.search(prefix)
    return words
  }
  public func search(range: CountableClosedRange<Int>) -> ContiguousArray<String> {
    return root.search(range: range)
  }
  public func match(_ pattern: String) -> [String] {
    return root.match(pattern: pattern)
  }
}
