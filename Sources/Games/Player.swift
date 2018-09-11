import Utility

/// A Begriffix player that selects by random
public struct Player {
  static var dict = loadDict()
  static func loadDict() -> Radix {
    let radix = Radix()
    guard let words = WordList.ScrabbleDict.words() else {return radix}
    words.forEach {radix.insert($0)}
    return radix
  }
  let vocabulary: Radix
  /// Initialize a new player
  public init(_ vocabulary: Radix? = nil) {
    self.vocabulary = vocabulary ?? Player.dict
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
    return .init(place, word)
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
