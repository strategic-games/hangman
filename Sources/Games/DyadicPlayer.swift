/// A player coordinator for dyadic games
public struct DyadicPlayers<T: Game> {
  /// A closure that takes a game and returns a move for this game
  public typealias Element = (_ game: T) -> T.Move?
  /// The player positions in a dyadic game
  public enum Position {
    /// The starting player and the responding player
    case starter, opponent
    var toggled: Position {
      switch self {
      case .starter: return .opponent
      case .opponent: return .starter
      }
    }
  }
  let starter: Element
  let opponent: Element
  private(set) var position: Position = .starter
  /// Initialize with two move closures
  public init(starter: @escaping(Element), opponent: @escaping(Element)) {
    self.starter = starter
    self.opponent = opponent
  }
  /// Get the current player's move closure
  subscript(_ position: Position) -> Element {
    switch position {
    case .starter: return starter
    case .opponent: return opponent
    }
  }
  /// Request a new move from the current player
  public func move(_ game: T) -> T.Move? {
    return self[position](game)
  }
  /// Toggle the current player position
  mutating func toggle() {
    position = position.toggled
  }
}
