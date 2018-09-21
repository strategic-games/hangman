import Utility

/// A game type
public protocol Game: Sequence {
  /// A displayable name for the game
  static var name: String {get}
  /// The move type of a game
  associatedtype Move
  /// The turn counter
  var turn: Int {get}
  associatedtype Update
  /// The current player
  var player: Update {get}
  /// Start the game
  mutating func play() throws
}

/// A type that can act as a board game
public protocol BoardGame {
  /// The type of a field value
  associatedtype Field
  /// A game board where values can be entered
  var board: Matrix<Field> {get}
  /// Returns a character representation of a field value
  func character(_ field: Field) -> Character
}

extension BoardGame {
  /// Returns a board where the field values are replaced with their character representations
  public var displayableBoard: Matrix<Character> {
    let values: [Character] = board.values.map(character)
    return Matrix(values: values, rows: board.rows, columns: board.columns)
  }
}

public protocol VerbalGame {
  associatedtype Letter
  associatedtype Word
}

/// A type that can act as a dyadic board game
public protocol DyadicGame: BoardGame {
  associatedtype Update
  /// The player who starts the game
  var starter: Update {get}
  /// The responding player
  var opponent: Update {get}
}

/// A game notification type
//public protocol GameStatus {}

/// General progress states of a game
public enum GameStatus<T: Game> {
  /// The game has a freshly setup game board
  case Ready
  /// Some changes were made to the board
  case Started
  /// A player has written a word
  case Moved(T.Move, T)
  /// The game has ended because a player couldn't prrovide a move
  case Ended
  case Failure(GameError<T>)
}

/// Errors that can happen when a move is inserted
public enum GameError<Game>: Error {
  /// The board does not contain this place
  case Place
  /// The word does not fit at the intended place
  case Word
}

/// Expose a closure property to be used for notification tracking
public protocol Trackable: Game {
  /// A closure that is executed with status notifications
  var notify: ((_ status: GameStatus<Self>) -> Void)? {get set}
}

public protocol Configurable {
  associatedtype Configuration
  init(from config: Configuration)
}
