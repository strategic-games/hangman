import HangMan

/// A Begriffix player
public struct RandomPlayer: Player {
  /// The player's vocabulary
  public let vocabulary: Radix
  /// Initialize a new player with a given vocabulary
  public init(vocabulary: Radix) {
    self.vocabulary = vocabulary
  }
  /// Return a move for a given game state
  public func deal(with state: State) -> Move? {
    switch state.phase {
    case .Restricted: return dealRestricted(with: state)
    case .Liberal: return dealLiberal(with: state)
    case .KnockOut: return nil
    }
  }
  private func dealRestricted(with state: State) -> Move? {
    var places = [Place:[String]]()
    let dir: Direction = state.player ? .Horizontal : .Vertical
    for count in stride(from: 8, through: 4, by: -1) {
      let p = state.scan(direction: dir, count: count)
      if p.isEmpty {continue}
      for s in p {
        let place = Place(start: s, direction: dir, count: count)
        let matches = match(state, place: place)
        if matches.isEmpty {continue}
        places[place] = matches
      }
    }
    return select(from: places)
  }
  private func dealLiberal(with state: State) -> Move? {
    var places = [Place:[String]]()
    for dir in Direction.allCases {
      for count in stride(from: 8, through: 3, by: -1) {
        let p = state.scan(direction: dir, count: count)
        if p.isEmpty {continue}
        for s in p {
          let place = Place(start: s, direction: dir, count: count)
          let matches = match(state, place: place)
          if matches.isEmpty {continue}
          places[place] = matches
        }
      }
    }
    return select(from: places)
  }
  /// Find the words that could be inserted at the given place
  func match(_ state: State, place: Place) -> [String] {
    let pattern = state.board[place].map {$0 ?? "?"}
    return vocabulary.match(String(pattern)).filter { word in
      let words = state.words(orthogonalTo: place, word: word)
      return words.allSatisfy {vocabulary.contains($0)}
    }
  }
  /// Select a move from valid places and their words
  func select(from places: [Place:[String]]) -> Move? {
    guard let (place, words) = places.randomElement() else {return nil}
    guard let word = words.randomElement() else {return nil}
    let wordSum = places.map({(_, words) in words.count}).sum()
    return Move(place: place, word: word, sum: wordSum)
  }
}

