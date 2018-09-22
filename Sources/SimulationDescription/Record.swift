import Games

/// A game move with some extra data
  struct Record: Codable {
    /// The place from the move returned from a player
    let place: Place
    /// The word from the move returned from a player
    let word: String
    /// The letter pattern the move was based on
    let pattern: String
    /// Indicates how many places on the board the player had to choose from
    let places: Int
    /// Indicates how many words the player had to choose from
    let words: Int
  }

