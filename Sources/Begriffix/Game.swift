/// A game that contains the preconditions to be played
public struct Game: Sequence, IteratorProtocol {
  public typealias Element = (State, Move)
  /// The starting player
  let starter = Player()
  /// The responding player
  let opponent = Player()
  /// The current game state
  var state = State()
  /// A bool indicating if the game has ended
  var ended: Bool = false
  /// The current player, depending on the state
  var player: Player {
    return state.player ? starter : opponent
  }
  /// Initialize a new game
  public init() {}
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
