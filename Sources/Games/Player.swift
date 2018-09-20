import Utility

/// A Begriffix player that selects by random
public struct Player {
  public let vocabulary: Vocabulary
  private var radix: Radix
  /// Initialize a new player
  public init(_ vocabulary: Vocabulary) {
    self.vocabulary = vocabulary
    radix = vocabulary.load()
  }
  public func move(_ game: Begriffix) -> Begriffix.Move? {
    guard let places = game.find() else {return nil}
    var result = [Place: [Begriffix.Word]]()
    places.forEach { place in
      let matches = match(game, place: place)
      if !matches.isEmpty {result[place] = matches}
    }
    guard let (place, words) = result.randomElement() else {return nil}
    guard let word = words.randomElement() else {return nil}
    return .init(place, word, result)
  }
  /// Find the words that could be inserted at the given place
  func match(_ game: Begriffix, place: Place) -> [Begriffix.Word] {
    let pattern = Array(game.board[place.area].joined())
    return radix.search(pattern: pattern).filter { word in
      let words = game.words(orthogonalTo: place, word: word)
      return words.allSatisfy {radix.contains($0)}
    }
  }
}

extension Player: Codable {
  private enum CodingKeys: String, CodingKey {
    case vocabulary
  }
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let vocabulary = try container.decode(Vocabulary.self, forKey: .vocabulary)
    self.init(vocabulary)
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(vocabulary, forKey: .vocabulary)
  }
}
