import Utility

/// A Begriffix player that selects by random
public struct Player {
  public typealias BegriffixHits = [Place: [BegriffixBoard.Word]]
  public typealias BegriffixStrategy = (BegriffixHits, Begriffix) -> Begriffix.Move?
  public static var randomSource = Xoshiro()
  private let vocabulary: Radix
  let begriffixStrategy: BegriffixStrategy
  /// Initialize a new player
  public init(_ vocabulary: Radix, begriffixStrategy: BegriffixStrategy? = nil) {
    self.vocabulary = vocabulary
    self.begriffixStrategy = begriffixStrategy ?? randomBegriffixStrategy
  }
  public init<S: Sequence>(_ vocabulary: S, begriffixStrategy: BegriffixStrategy? = nil) where S.Element == String {
    let radix = Radix()
    radix.insert(vocabulary)
    self.vocabulary = radix
    self.begriffixStrategy = begriffixStrategy ?? randomBegriffixStrategy
  }
  public func move(_ game: Begriffix) -> Begriffix.Move? {
    guard let places = game.find() else {return nil}
    var hits = [Place: [BegriffixBoard.Word]](minimumCapacity: places.count)
    places.forEach {
      let matches = match(game, place: $0)
      if !matches.isEmpty {hits[$0] = matches}
    }
    return begriffixStrategy(hits, game)
  }
  /// Find the words that could be inserted at the given place
  func match(_ game: Begriffix, place: Place) -> [BegriffixBoard.Word] {
    let pattern = game.board.pattern(of: place)
    return vocabulary.search(pattern: pattern)
      .filter {game.isValid($0, at: place)}
  }
}
