import Utility

/// A Begriffix player that selects by random
public struct Player {
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
    var hits = [Place: [Begriffix.Word]](minimumCapacity: places.count)
    places.forEach {
      let matches = match(game, place: $0)
      if !matches.isEmpty {hits[$0] = matches}
    }
    return begriffixStrategy(hits, game)
  }
  /// Find the words that could be inserted at the given place
  func match(_ game: Begriffix, place: Place) -> [Begriffix.Word] {
    let pattern = Array(game.board[place.area].joined())
    return vocabulary.search(pattern: pattern)
      .filter { word in
        return game.isValid(word: word, place: place)
    }
  }
}
