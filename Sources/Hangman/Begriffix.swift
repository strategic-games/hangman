/// A type that can act as a board game
public protocol BoardGame: Sequence, IteratorProtocol {
  /// A type that can act as a game board
  associatedtype Board: Collection
  /// The move type of a game
  associatedtype Move
  /// A game board where values can be entered
  var board: Board {get}
  /// The turn counter
  var turn: Int {get}
  /// The current player
  var player: Player {get}
}

/// A type that can act as a dyadic board game
public protocol DyadicGame: BoardGame {
  /// The player who starts the game
  var starter: Player {get}
  /// The responding player
  var opponent: Player {get}
}

/// A begriffix game
public struct Begriffix: DyadicGame {
  public typealias Letter = Unicode.Scalar
  public typealias Word = [Letter]
  public typealias Pattern = [Letter?]
  /// A begriffix move
  public struct Move {
    /// The place where the word should be written
    public let place: Place
    /// The word to write in this move
    public let word: Word
    /// The collection which the move has been selected from
    public let places: [Place: [Word]]?
    /// Initialize a move with given values
    public init(place: Place, word: Word, places: [Place: [Word]]? = nil) {
      self.place = place
      self.word = word
      self.places = places
    }
  }
  /// game phases depending on the progress
  public enum Phase {
    /// Players must write words with at least four characters, starting player must write horizontally, and opponent must write vertically
    case Restricted(Direction)
    /// Any words and directions are allowed
    case Liberal
    /// not yet implemented
    case KnockOut
  }
  /// Some human-generated start letters
  public static let startLetters: [StaticString] = ["laer", "jaul", "kiod", "osni", "brau", "teoc", "ziaf", "prau", "muah", "wuag", "roed", "kanu", "giut", "fued", "ingo", "ehmo", "pois", "biel", "ormi"]
  public var board: Matrix<Letter?>
  private var numericalBoard: Matrix<Int> {
    return board.map2 {$0 != nil ? 1 : 0}
  }
  public let starter: Player
  public let opponent: Player
  public private(set) var turn: Int = 0
  private var playerIndex: Bool = true
  public var player: Player {
    return playerIndex ? starter : opponent
  }
  /// Indicates if the game has ended
  var ended: Bool = false
  /// The current game phase which is derived from turn
  public var phase: Phase {
    if turn == 0 {return .Restricted(playerIndex ? .Horizontal : .Vertical)}
    if turn <= 5 {return .Liberal}
    return .KnockOut
  }
  /// Initialize a new begriffix game with given players
  public init(startLetters: [[Letter?]], starter: Player, opponent: Player) {
    board = Board(repeating: nil, size: Dimensions(8))
    board[Position(3, 3), Dimensions(2, 2)] = Board(startLetters)
    self.starter = starter
    self.opponent = opponent
  }
  /// Advance the game for one move
  public mutating func next() -> (Begriffix, Move)? {
    if let move = player.deal(with: self) {
      playerIndex.toggle()
      if playerIndex {turn += 1}
      board[move.place] = Array(move.word)
      return (self, move)
    } else {
      ended = true
      return nil
    }
  }
  /// Return every position where words with given direction and length could be inserted
  func scan(direction: Direction, count: Int) -> [Position] {
    let k2 = direction.kernel(2)
    let k3 = direction.kernel(3)
    let f2 = numericalBoard.conv2(k2).extend(k2)
    let f3 = numericalBoard.conv2(k3).extend(k3).conv2(k2).dilate(k2)
    let w = direction.kernel(count)
    let w2 = f2.conv2(w)
    let w3 = f3.conv2(w)
    let size = w2.size
    let w2_inv = w2.map {$0 >= 2 ? 1 : 0}
    let w3_inv = w3.map {$0 == 0 ? 1 : 0}
    let allowed = w2_inv*w3_inv
    let positions = allowed.enumerated().filter({$1 == 1}).map({(n, _) in size.position(n)})
    if size.count == count {return positions}
    return positions.filter { p in
      switch direction {
      case .Horizontal:
        if p.j > 0 && board[Position(p.i, p.j-1)] != nil {return false}
        let end = p.j+count
        if end < board.size.n && board[Position(p.i, end)] != nil {return false}
      case .Vertical:
        if p.i > 0 && board[Position(p.i-1, p.j)] != nil {return false}
        let end = p.i+count
        if end < board.size.m && board[Position(end, p.j)] != nil {return false}
      }
      return true
    }
  }
  /// Return the words crossing the given place after inserting a given word
  func words(orthogonalTo place: Place, word: Word) -> [Word] {
    var board = self.board
    board[place] = word
    let (lines, around) = place.lines()
    return board.lines(by: place.direction.toggled(), in: lines).compactMap {
      let r = $0.indices(around: around, surround: nil)
      if r.count < 3 {return nil}
      let word = $0[r].compactMap {$0}
      return word
    }
  }
  /// Indicate if the given place is usable
  public func contains(place: Place) -> Bool {
    return scan(direction: place.direction, count: place.count).contains(place.start)
  }
}

extension BidirectionalCollection where Element: Equatable {
  /// Returns the indices around a given index to return a slice that is surrounded by a given element
  func indices(around i: Index, surround: Element) -> Range<Index> {
    precondition(indices.contains(i), "i out of bounds")
    var start = i
    var end = i
    while start > startIndex {
      let next = index(before: start)
      if self[next] == surround {break}
      start = next
    }
    while end < endIndex {
      formIndex(after: &end)
      if end == endIndex || self[end] == surround {break}
    }
    return start..<end
  }
}
