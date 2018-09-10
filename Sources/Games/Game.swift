/// A game type
public protocol Game {
  /// A displayable name for the game
  static var name: String {get}
  /// The move type of a game
  associatedtype Command
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
  /// A type that can act as a game board
  associatedtype Board
  /// A game board where values can be entered
  var board: Board {get}
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
public protocol GameStatus {}

/// Expose a closure property to be used for notification tracking
public protocol Trackable {
  /// The notification type
  associatedtype Status: GameStatus
  /// A closure that is executed with status notifications
  var notify: ((_ status: Status) -> Void)? {get set}
}
