/// A type that can act as a dyadic board game
public protocol DyadicGame: BoardGame {
  /// The player who starts the game
  var starter: Player {get}
  /// The responding player
  var opponent: Player {get}
}


