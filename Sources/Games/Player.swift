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
  /// Initialize a new player
  public init() {}
  public func move(_ game: Begriffix) -> Begriffix.Command {
    guard let places = game.find() else {return .GiveUp}
    var result = [Place: [Begriffix.Word]]()
    places.forEach { place in
      let matches = match(game, place: place)
      if !matches.isEmpty {result[place] = matches}
    }
    guard let (place, words) = result.randomElement() else {return .GiveUp}
    guard let word = words.randomElement() else {return .GiveUp}
    return .Write(word, place)
  }
  /// Find the words that could be inserted at the given place
  func match(_ game: Begriffix, place: Place) -> [Begriffix.Word] {
    let pattern = Array(game.board[place.area].joined())
    return Player.dict.search(pattern: pattern).filter { word in
      let words = game.words(orthogonalTo: place, word: word)
      return words.allSatisfy {Player.dict.contains($0)}
    }
  }
}
