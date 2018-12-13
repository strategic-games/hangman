import Utility

/// A begriffix game
public struct Begriffix: DyadicGame, Trackable {
  public typealias Word = [Unicode.Scalar]
  public typealias Board = BegriffixBoard
  public typealias Status = GameStatus<Begriffix>
  public typealias Notify = ((_ status: Status) -> Void)?
  public typealias Update = (_ game: Begriffix) -> Move?
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
  /// phases of a game which is currently playing
  public enum Phase {
    /// Players must write words with at least four letters,
    /// starting player must write horizontally, and opponent vertically
    case restricted(Direction)
    /// Any words and directions are allowed
    case liberal
  }
  public static let name = "Begriffix"
  /// How many times the starter and opponent have provided a move
  private var moveCount: Int = 0
  public var turn: Int {
    return moveCount/2
  }
  // public private(set) var turn: Int = 0
  private var playerIndex: Bool = true
  public private(set) var board: Board
  /// A reference vocabulary which is used for word validation
  public let vocabulary: Radix?
  /// The first player in a turn
  public let starter: Update
  /// The second player in a turn
  public let opponent: Update
  /// The player who would be asked for the next move
  public var player: Update {
    return moveCount % 2 == 0 ? starter : opponent
  }
  /// The current game phase which is derived from turn
  public var phase: Phase {
    if turn == 0 {return .restricted(playerIndex ? .horizontal : .vertical)}
    return .liberal
  }
  public var notify: Notify
  /// Initialize a new begriffix game with given board and players
  public init(board: Board, starter: @escaping(Update), opponent: @escaping(Update), vocabulary: Radix? = nil) {
    self.board = board
    self.starter = starter
    self.opponent = opponent
    self.vocabulary = vocabulary
  }
  /// Play the game and pass notifications if a notify callback is set
  public mutating func play() throws {
    notify?(.started)
    repeat {
      guard let move = player(self) else {
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
    moveCount += 1
    // playerIndex.toggle()
    // if playerIndex {turn += 1}
  }
  /// Find every place where words with allowed direction and length could be written
  public func find() -> [Place]? {
    let direction: [Direction], min: Int
    switch phase {
    case .restricted(let dir):
      min = 4
      direction = [dir]
    case .liberal:
      min = 3
      direction = Direction.allCases
    }
    var places = [Place]()
    for dir in direction {
      // stride(from: 8, through: min, by: -1)
      for count in min...board.sideLength {
        places += board.find(direction: dir, count: count).map {Place(start: $0, direction: dir, count: count)}
      }
    }
    return places
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
    guard let move = player(self) else {return nil}
    let currentGame = self
    do {
      try insert(move)
    } catch {
      return nil
    }
    return (currentGame, move)
  }
}
