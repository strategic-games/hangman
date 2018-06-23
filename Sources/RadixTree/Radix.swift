public final class Radix {
  let root = Root()
  public init() {}
  public func insert(_ word: String) {
    root.insert(search: word)
  }
  public func insert<S: Sequence>(_ s: S) where S.Element == String {
    for x in s {
      root.insert(search: x)
    }
  }
  public func contains(_ word: String) -> Bool {
    let node = root.find(word: word)
    return node != nil ? true : false
  }
  public func search() -> [String] {
    return root.search("")
  }
}
