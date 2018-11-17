/// Strategies for move selection

/// Select a random move if possible
public func randomBegriffixStrategy(hits: Player.BegriffixHits, game: Begriffix) -> Begriffix.Move? {
  guard let (place, words) = hits.randomElement(using: &Player.randomSource) else {return nil}
  guard let word = words.randomElement(using: &Player.randomSource) else {return nil}
  return .init(place, word, hits)
}

/// Select a random word from the shortest pattern
public func shortBegriffixStrategy(hits: Player.BegriffixHits, game: Begriffix) -> Begriffix.Move? {
  guard let (place, words) = hits.min(by: {
    let left = game.pattern(of: $0.key)
    let right = game.pattern(of: $1.key)
    return left.count <= right.count
  }) else {return nil}
guard let word = words.randomElement(using: &Player.randomSource) else {return nil}
return .init(place, word, hits)
}

/// Select a random word from the longest pattern
public func longBegriffixStrategy(hits: Player.BegriffixHits, game: Begriffix) -> Begriffix.Move? {
  guard let (place, words) = hits.max(by: {
    let left = game.pattern(of: $0.key)
    let right = game.pattern(of: $1.key)
    return left.count <= right.count
  }) else {return nil}
  guard let word = words.randomElement(using: &Player.randomSource) else {return nil}
  return .init(place, word, hits)
}

/// Prefer words for patterns starting with the given letters
public func availabilityBegriffixStrategy(hits: Player.BegriffixHits, game: Begriffix) -> Begriffix.Move? {
  guard let (place, words) = hits.min(by: {
    let left = game.pattern(of: $0.key).firstIndex(where: {$0 != nil}) ?? 0
    let right = game.pattern(of: $1.key).firstIndex(where: {$0 != nil}) ?? 0
    return left <= right
  }) else {return nil}
  guard let word = words.randomElement(using: &Player.randomSource) else {return nil}
  return .init(place, word, hits)
}

/// Minimize the number of places for the next player
public func minPlacesBegriffixStrategy(hits: Player.BegriffixHits, game: Begriffix) -> Begriffix.Move? {
  do {
    guard let (place, words) = try hits.min(by: {
      var leftGame = game
      var rightGame = game
      try leftGame.insert(.init($0.key, $0.value[0]))
      try rightGame.insert(.init($1.key, $1.value[0]))
      return leftGame.find()?.count ?? 0 <= rightGame.find()?.count ?? 0
    }) else {return nil}
    guard let word = words.randomElement(using: &Player.randomSource) else {return nil}
    return .init(place, word, hits)
  } catch {
    return nil
  }
}
