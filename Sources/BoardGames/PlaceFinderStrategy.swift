protocol PlaceFinderStrategy {
  associatedtype Board
  func scan(_ board: Board, options: PlaceOptions) -> [Kernel:[Position]]
}

struct PlaceOptions: OptionSet {
  let rawValue: Int
  static let horizontal = PlaceOptions(rawValue: 1<<0)
  static let vertical = PlaceOptions(rawValue: 1<<1)
  static let includeThree = PlaceOptions(rawValue: 1<<2)
  static let all: PlaceOptions = [.horizontal, .vertical, .includeThree]
}

struct PlaceFinder: PlaceFinderStrategy {
  typealias Board = Matrix<Int>
  typealias Result = [Kernel:[Position]]
  struct KernSet {
    var k2: Kernel
    var k3: Kernel
    var k_words: [Kernel]
    init(_ dir: Kernel.Direction, max: Int = 8) {
      k2 = Kernel(count: 2, direction: dir)
      k3 = Kernel(count: 3, direction: dir)
      k_words = (4...max).map {Kernel(count: $0, direction: dir)}
    }
  }
  var kern_h: KernSet
  var kern_v: KernSet
  init(_ boardSize: Dimensions) {
    kern_h = KernSet(.Horizontal, max: boardSize.n)
    kern_v = KernSet(.Vertical, max: boardSize.m)
  }
  func scan(_ board: Board, options: PlaceOptions) -> Result {
    var result = Result()
    if options.contains(.horizontal) {
      result.merge(scan(board, set: kern_h, includeThree: options.contains(.includeThree))) {(_, new) in new}
    }
    if options.contains(.vertical) {
      result.merge(scan(board, set: kern_v, includeThree: options.contains(.includeThree))) {(_, new) in new}
    }
    return result
  }
  func scan(_ board: Board, set: KernSet, includeThree: Bool) -> Result {
    let f2 = board.conv2(set.k2.full, extend: true)
    let f3 = board.conv2(set.k3.full, extend: true)
    var found = Result()
    for w in set.k_words {
      let w2 = f2.conv2(w.full)
      let w3 = f3.conv2(w.full)
      let w2_inv = w2.map2 {$0 >= 2 ? 1 : 0}
      let w3_inv = w3.map2 {$0 == 0 ? 1 : 0}
      let allowed = zip(w2_inv, w3_inv).map(*)
      let compressed = allowed.enumerated().filter({(_, x) in x == 1}).map({(n, _) -> Position in w2.size.position(n)})
      found[w] = compressed
    }
    return found
  }
}
