struct Game: Sequence, IteratorProtocol {
  typealias Element = State
  let starter = Player()
  let opponent = Player()
  var state: State
  var ended: Bool = false
  var player: Player {
    return state.player ? starter : opponent
  }
  mutating func next() -> State? {
    if ended {
      return nil
    }
    if let insertion = player.deal(with: state) {
      defer {state = state + insertion}
      return state
    } else {
      ended = true
      return state
    }
  }
}
