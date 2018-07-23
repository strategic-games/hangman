/// A game move that is returned by a player
public struct Move: Hashable {
  /// The place where the word should be written
  let place: Place
  /// The word to write in this move
  let word: String
  let sum: Int
  public init(place: Place, word: String, sum: Int) {
    self.place = place
    self.word = word
    self.sum = sum
  }
}
