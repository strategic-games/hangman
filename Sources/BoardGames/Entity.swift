/// A protocol for types that can be used as game entities in board matrices
protocol Entity {
  /// A one character representation of the entity for printing board matrices
  var symbol: Character {get}
  /// Indicates if the entity is set or not set
  var isFilled: Bool {get}
  /// Create an entity from a one-character representation
  init(from symbol: Character)
}

extension Bool: Entity {
  /// If booleans are sufficient for games, they are represented as squares (true) or dots (false)
  var symbol: Character {
    return self ? "\u{25A0}" : "."
  }
  /// If an entity is true, it is set
  var isFilled: Bool {return self}
  /// create a board matrix from symbols
  init(from symbol: Character) {
    self = symbol == "\u{25A0}"
  }
}

extension Optional: Entity where Wrapped == Character {
  /// Optional characters are printed as themselves or dots (nil)
  var symbol: Character {
    return self ?? "."
  }
  /// A nil character indicates an empty field, the entity is not set
  var isFilled: Bool {return self != nil}
  /// Create board matrix from character symbols, converting dots to nil
  init(from symbol: Character) {
    self = symbol == "." ? nil : symbol
  }
}
