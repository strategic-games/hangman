/// A game move that is returned by a player
public struct Move: Hashable {
  /// The place where the word should be written
  public let place: Place
  /// The word to write in this move
  public let word: String
  public let places: [Place:[String]]?
  public init(place: Place, word: String, places: [Place:[String]]? = nil) {
    self.place = place
    self.word = word
    self.places = places
  }
}
