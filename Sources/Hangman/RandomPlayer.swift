/// A Begriffix player
public struct RandomPlayer: Player {
  /// The player's vocabulary
  public let vocabulary: Radix
  /// Initialize a new player with a given vocabulary
  public init(vocabulary: Radix) {
    self.vocabulary = vocabulary
  }
  public func deal(with game: Begriffix) -> Begriffix.Move? {
    switch game.phase {
    case let .Restricted(dir): return dealRestricted(with: game, dir: dir)
    case .Liberal: return dealLiberal(with: game)
    case .KnockOut: return nil
    }
  }
  private func dealRestricted(with game: Begriffix, dir: Direction) -> Begriffix.Move? {
    var places = [Place: [Begriffix.Word]]()
    for count in stride(from: 8, through: 4, by: -1) {
      let p = game.scan(direction: dir, count: count)
      if p.isEmpty {continue}
      for s in p {
        let place = Place(start: s, direction: dir, count: count)
        let matches = match(game, place: place)
        if matches.isEmpty {continue}
        places[place] = matches
      }
    }
    return select(from: places)
  }
  private func dealLiberal(with game: Begriffix) -> Begriffix.Move? {
    var places = [Place: [Begriffix.Word]]()
    for dir in Direction.allCases {
      for count in stride(from: 8, through: 3, by: -1) {
        let p = game.scan(direction: dir, count: count)
        if p.isEmpty {continue}
        for s in p {
          let place = Place(start: s, direction: dir, count: count)
          let matches = match(game, place: place)
          if matches.isEmpty {continue}
          places[place] = matches
        }
      }
    }
    return select(from: places)
  }
  /// Find the words that could be inserted at the given place
  func match(_ game: Begriffix, place: Place) -> [Begriffix.Word] {
    let pattern = game.board[place]
    return vocabulary.search(pattern: pattern).filter { word in
      let words = game.words(orthogonalTo: place, word: word)
      return words.allSatisfy {vocabulary.contains($0)}
    }
  }
  /// Select a move from valid places and their words
  func select(from places: [Place: [Begriffix.Word]]) -> Begriffix.Move? {
    guard let (place, words) = places.randomElement() else {return nil}
    guard let word = words.randomElement() else {return nil}
    return Begriffix.Move(place: place, word: word, places: places)
  }
}
