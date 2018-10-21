import Utility

/// A Begriffix player that selects by random
public struct Player {
  private var vocabulary: Radix
  /// Initialize a new player
  public init(_ vocabulary: Radix) {
    self.vocabulary = vocabulary
  }
  public init<S: Sequence>(_ vocabulary: S) where S.Element == String {
    let radix = Radix()
    radix.insert(vocabulary)
    self.vocabulary = radix
  }
  public func move(_ game: Begriffix) -> Begriffix.Move? {
    guard let places = game.find() else {return nil}
    var hits = [Place: [Begriffix.Word]](minimumCapacity: places.count)
    places.forEach {
      let matches = match(game, place: $0)
      if !matches.isEmpty {hits[$0] = matches}
    }
    guard let (place, words) = hits.randomElement() else {return nil}
    guard let word = words.randomElement() else {return nil}
    return .init(place, word, hits)
  }
  /// Find the words that could be inserted at the given place
  func match(_ game: Begriffix, place: Place) -> [Begriffix.Word] {
    let pattern = Array(game.board[place.area].joined())
    return vocabulary.search(pattern: pattern).filter { word in
      let words = game.words(orthogonalTo: place, word: word)
      return words.allSatisfy {vocabulary.contains($0)}
    }
  }
}
