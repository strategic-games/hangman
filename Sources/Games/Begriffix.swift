import Utility

/// A begriffix game
public struct Begriffix: DyadicGame, Trackable {
  public typealias Word = [Unicode.Scalar]
  public typealias Board = BegriffixBoard
  public typealias MinWordLength = (first: Int, other: Int)
  /// Modes of restriction for the writing direction
  public enum DirectionRestrictionMode {
    /// Starter is unrestricted, opponent must write orthogonally to starter
    case variable
    /// Starter must write horizontally, opponent must write vertically
    case fixed
  }
  public typealias DirectionRestrictions = (first: DirectionRestrictionMode?, other: DirectionRestrictionMode?)
  public typealias Players = DyadicPlayers<Begriffix>
  public typealias Status = GameStatus<Begriffix>
  public typealias Notify = ((_ status: Status) -> Void)?
  /// A message type which contains data to advance the game
  public struct Move {
    /// The board position where the new word should be written
    public let place: Place
    /// The new word that should be written
    public let word: Word
    /// The totality of all possible moves.
    /// Each entry consists of a valid place and an array of words matching the according pattern.
    /// If player types are aware of this information, they can provide it with their moves.
    public let hits: [Place: [Word]]?
    /// Initialize a new move
    public init(_ place: Place, _ word: Word, _ hits: [Place: [Word]]? = nil) {
      assert(place.count == word.count, "place and word length must be equal")
      self.place = place
      self.word = word
      self.hits = hits
    }
  }
  public static let name = "Begriffix"
  /// The already inserted moves
  public private(set) var moves: [Move] = []
  public var turn: Int {
    return moves.count / 2
  }
  /// The current player position
  public var player: Players.Position {
    return moves.count % 2 == 0 ? .starter : .opponent
  }
  /// The players coordinator
  public var players: Players
  /// The game board
  public private(set) var board: Board
  /// A reference vocabulary which is used for word validation
  public let vocabulary: Radix?
  /// The minimum word lengths for the two game phases
  public let minWordLength: MinWordLength
  /// The restrictions of writing direction in and after the first turn
  public let directionRestrictions: DirectionRestrictions
  public var notify: Notify
  /// Initialize a new begriffix game
  public init(
    board: Board,
    players: Players,
    minWordLength: MinWordLength = (first: 5, other: 4),
    directionRestrictions: DirectionRestrictions = (first: .variable, other: nil),
    vocabulary: Radix? = nil
  ) {
    self.board = board
    self.players = players
    self.minWordLength = minWordLength
    self.directionRestrictions = directionRestrictions
    self.vocabulary = vocabulary
  }
  /// Play the game and pass notifications if a notify callback is set
  public mutating func play() throws {
    notify?(.started)
    repeat {
      guard let move = players[player](self) else {
        notify?(.ended)
        break
      }
      try insert(move)
      notify?(.moved(move, self))
    } while true
  }
  /// Apply a move to the game
  public mutating func insert(_ move: Move) throws {
    try board.insert(move.word, at: move.place)
    moves.append(move)
  }
  /// The direction which can currently be used to write, nil if not restricted
  public var dir: Direction? {
    guard let mode = turn == 0 ? directionRestrictions.first : directionRestrictions.other else {return nil}
    switch mode {
    case .fixed:
      return self.player == .starter ? .horizontal : .vertical
    case .variable:
      return self.player == .opponent ? moves.last?.place.direction.orthogonal : nil
    }
  }
  /// Find every place where words with allowed direction and length could be written
  public func find() -> FlattenCollection<[[Place]]> {
    let min = turn == 0 ? minWordLength.first : minWordLength.other
    if let dir = self.dir {
      return (min...board.sideLength)
        .concurrentMap {self.board.find(direction: dir, count: $0)}
        .joined()
    } else {
      return Direction.allCases
        .map { dir in
          (min...board.sideLength).map {(dir, $0)}
        }
        .joined()
        .concurrentMap {self.board.find(direction: $0.0, count: $0.1)}
        .joined()
    }
  }
    /// Indicates if a word fits a pattern
  /// Indicates if a word fits the pattern at a given place,
  /// and if the word and orthogonal words exist in the reference vocabulary.
  /// If no vocabulary is given, only the pattern is checked.
  func isValid(_ word: Board.Word, at place: Place) -> Bool {
    guard board.isValid(word, at: place) else {return false}
    guard let vocabulary = vocabulary else {return true}
    guard vocabulary.contains(word) else {return false}
    let words = board.words(orthogonalTo: place, word: word)
    guard words.allSatisfy({vocabulary.contains($0)}) else {return false}
    return true
  }
}

extension Begriffix: Sequence, IteratorProtocol {
  /// Try to get a valid move from the current player and apply that move.
  ///
  /// - Returns: The game state which is shown to the player and the move provided by the player.
  ///If the player cannot provide a valid move, nil is returned.
  public mutating func next() -> (Begriffix, Move)? {
    guard let move = players[player](self) else {return nil}
    let currentGame = self
    do {
      try insert(move)
    } catch {
      return nil
    }
    return (currentGame, move)
  }
}
