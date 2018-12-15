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

public protocol BoardGame: Game {
  associatedtype Board
  var board: Board {get}
}

public protocol VerbalGame {
  associatedtype Letter
  associatedtype Word
}

/// A type that can act as a dyadic board game
public protocol DyadicGame: BoardGame {
  var players: DyadicPlayers<Self> {get}
}

/// General progress states of a game
public enum GameStatus<T: Game> {
  /// The game has a freshly setup game board
  case ready
  /// Some changes were made to the board
  case started
  /// A player has written a word
  case moved(T.Move, T)
  /// The game has ended because a player couldn't prrovide a move
  case ended
  case failure(Error)
}

/// Expose a closure property to be used for notification tracking
public protocol Trackable: Game {
  /// A closure that is executed with status notifications
  var notify: ((_ status: GameStatus<Self>) -> Void)? {get set}
}
