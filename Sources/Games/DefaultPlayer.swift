import Foundation
import Utility

/// A Begriffix player that selects by random
public struct DefaultPlayer: BegriffixPlayer {
  static var dict = loadDict()
  static func loadDict() -> Radix {
    //let file = URL(fileURLWithPath: input.value ?? "Resources/dictionaries/german.txt")
    //let content = try String(contentsOf: file).lowercased()
    //let radix = Radix(text: content)
    print(Bundle(for: Radix.self).url(forResource: "german", withExtension: "txt", subdirectory: "dictionaries")?.description ?? "none")
    let radix = Radix()
    return radix
  }
  /// Initialize a new player with a given id and vocabulary
  public init() {}
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
    return DefaultPlayer.dict.search(pattern: pattern).filter { word in
      let words = game.words(orthogonalTo: place, word: word)
      return words.allSatisfy {DefaultPlayer.dict.contains($0)}
    }
  }
}
