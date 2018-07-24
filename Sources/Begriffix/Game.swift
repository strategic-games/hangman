import HangMan

/// A game that contains the preconditions to be played
public struct Game: Sequence, IteratorProtocol {
  public typealias Element = (State, Move)
  /// The starting player
  public let starter: Player
  /// The responding player
  public let opponent: Player
  /// The current game state
  var state = State()
  /// A bool indicating if the game has ended
  var ended: Bool = false
  /// The current player, depending on the state
  public var player: Player {
    return state.player ? starter : opponent
  }
  /// Initialize a new game
  public init(starter: Player, opponent: Player) {
    self.starter = starter
    self.opponent = opponent
  }
  public init(vocabulary: Radix) {
    starter = RandomPlayer(vocabulary: vocabulary)
    opponent = starter
  }
  /// Advance the game for one move
  public mutating func next() -> (State, Move)? {
    if let move = player.deal(with: state) {
        state = state + move
      return (state, move)
    } else {
      ended = true
      return nil
    }
  }
}
