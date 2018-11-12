import Utility

/// A Begriffix player that selects by random
public struct Player {
  /// Preferences for move selection
  public enum Preference: Int {
    /// Select a random move if possible
    case random = 0
    /// Prefer words for patterns starting with the given letters
    case availability
    /// Select the longest word
    case long
    /// Select the shortest word
    case short
    func select(_ hits: [Place: [Begriffix.Word]], game: Begriffix) -> Begriffix.Move? {
      let hit: (key: Place, value: [Begriffix.Word])?
      switch self {
      case .random:
        hit = hits.randomElement()
      case .availability:
        hit = hits.min(by: {
          let left = game.pattern(of: $0.key).firstIndex(where: {$0 != nil}) ?? 0
          let right = game.pattern(of: $1.key).firstIndex(where: {$0 != nil}) ?? 0
          return left <= right
        })
      case .long:
        hit = hits.max(by: {
          let left = game.pattern(of: $0.key)
          let right = game.pattern(of: $1.key)
          return left.count <= right.count
        })
      case .short:
        hit = hits.min(by: {
          let left = game.pattern(of: $0.key)
          let right = game.pattern(of: $1.key)
          return left.count <= right.count
        })
      }
      guard let (place, words) = hit else {return nil}
      guard let word = words.randomElement() else {return nil}
      return .init(place, word, hits)
    }
  }
  private let vocabulary: Radix
  let preference: Preference
  /// Initialize a new player
  public init(_ vocabulary: Radix, preference: Preference? = nil) {
    self.vocabulary = vocabulary
    self.preference = preference ?? .random
  }
  public init<S: Sequence>(_ vocabulary: S, preference: Preference? = nil) where S.Element == String {
    let radix = Radix()
    radix.insert(vocabulary)
    self.vocabulary = radix
    self.preference = preference ?? .random
  }
  public func move(_ game: Begriffix) -> Begriffix.Move? {
    guard let places = game.find() else {return nil}
    var hits = [Place: [Begriffix.Word]](minimumCapacity: places.count)
    places.forEach {
      let matches = match(game, place: $0)
      if !matches.isEmpty {hits[$0] = matches}
    }
    return preference.select(hits, game: game)
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
