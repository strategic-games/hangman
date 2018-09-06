import Utility
import Games

/// A Begriffix player that selects by random
public struct RandomPlayer: BegriffixPlayer {
  /// The player's vocabulary
  public let vocabulary: Radix
  /// Initialize a new player with a given id and vocabulary
  public init(vocabulary: Radix) {
    self.vocabulary = vocabulary
  }
  public func move(_ game: Begriffix) -> Begriffix.Move? {
    guard let places = game.find() else {return nil}
    var result = [Begriffix.Place: [Begriffix.Word]]()
    places.forEach { place in
      let matches = match(game, place: place)
      if !matches.isEmpty {result[place] = matches}
    }
    guard let (place, words) = result.randomElement() else {return nil}
    guard let word = words.randomElement() else {return nil}
    return Begriffix.Move(place: place, word: word, places: result)
  }
  /// Find the words that could be inserted at the given place
  func match(_ game: Begriffix, place: Begriffix.Place) -> [Begriffix.Word] {
    let pattern = Array(game.board[place.area].joined())
    return vocabulary.search(pattern: pattern).filter { word in
      let words = game.words(orthogonalTo: place, word: word)
      return words.allSatisfy {vocabulary.contains($0)}
    }
  }
}
