/// A type that can act as a board game
public protocol BoardGame: Sequence, IteratorProtocol {
  /// A type that can act as a game board
  associatedtype Board
  associatedtype Player
  /// The move type of a game
  associatedtype Move
  /// A displayable name for the game
  static var name: String {get}
  /// A game board where values can be entered
  var board: Board {get}
  /// The turn counter
  var turn: Int {get}
  /// The current player
  var player: Player {get}
}
