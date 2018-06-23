class QuickDic {
  private var roots = [Hangman]()
  init() {}
  public init<Source>(_ sequence: Source) where Source: Sequence, Source.Element == String {
    sequence.forEach {insert($0)}
  }
  func insert(_ word: String) {
    var i = word.startIndex
    for n in 0..<word.count {
      if roots.count <= n {
        roots.append(Hangman())
      }
      roots[n].insert(word.suffix(from: i) + word.prefix(upTo: i))
      i = word.index(after: i)
    }
  }
  func remove(_ word: String) {
    let words: [String] = word.rotated()
    for (n, x) in words.enumerated() {
      if roots.count <= n {
        break
      }
      roots[n].remove(x)
    }
  }
  func contains(_ word: String) -> Bool {
    return roots[0].contains(word)
  }
  func match(_ pattern: String) -> [String] {
    guard let i = pattern.firstIndex(where: {$0 != "?"}) else {
      return roots[0].match(pattern)
    }
    let n: Int = pattern[pattern.startIndex..<i].count
    let new = pattern.movedFirst(n)
    return roots[n].match(new).map {$0.movedLast(n)}
  }
}
