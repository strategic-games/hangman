struct Game: Sequence, IteratorProtocol {
  typealias Element = (State, Move)
  let starter = Player()
  let opponent = Player()
  var state = State()
  var ended: Bool = false
  var player: Player {
    return state.player ? starter : opponent
  }
  mutating func next() -> (State, Move)? {
    if let move = player.deal(with: state) {
        state = state + move
      return (state, move)
    } else {
      ended = true
      return nil
    }
  }
}
