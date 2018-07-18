/// A game move that is returned by a player
public struct Move: Hashable {
  /// The place where the word should be written
  let place: Place
  /// The word to write in this move
  let word: String
  let sum: Int
}
