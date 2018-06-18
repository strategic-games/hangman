struct BoardGameIterator: IteratorProtocol {
  let turns: Int, players: Int
  var count = 0
  var moves: Int {return players*turns}
  var progress: (turn: Int, player: Int) {
    return (turn: count/players, player: count%players)
  }
  init(_ options: BoardGameOptions) {
    turns = options.turns
    players = options.players
  }
  mutating func next() -> (turn: Int, player: Int)? {
    if count == moves {
      return nil
    } else {
      defer {count += 1}
      return progress
    }
  }
}
