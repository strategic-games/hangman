import Utility

/// A begriffix game
public struct Begriffix: Game&BoardGame&Trackable {
  /// The type of a letter, can be written at one board position
  public typealias Letter = Unicode.Scalar
  /// The type of a word which is a sequence of letters
  public typealias Word = [Letter]
  /// A sequence of optional letters, nil means that any letter can be used there
  public typealias Pattern = [Letter?]
  public typealias Board = Matrix<Letter?>
  public typealias Notify = ((_ status: Status) -> Void)?
  public typealias Update = (_ game: Begriffix) -> Command
  public enum Command {
    case Write(Word, Place)
    case GiveUp
  }
  /// General progress states of a game
  public enum Status: GameStatus {
    /// The game has a freshly setup game board
    case Ready
    /// Some changes were made to the board
    case Started
    /// A player has written a word
    case moved(Command)
    /// The game has ended because a player couldn't prrovide a move
    case Ended
  }
  /// Errors that can happen when a move is inserted
  public enum MoveError: Error {
    /// The board does not contain this place
    case Place
    /// The word does not fit at the intended place
    case Word
  }
  /// phases of a game which is currently playing
  public enum Phase {
    /// Players must write words with at least four characters, starting player must write horizontally, and opponent must write vertically
    case Restricted(Direction)
    /// Any words and directions are allowed
    case Liberal
    /// not yet implemented
    case KnockOut
  }
  public static let name = "Begriffix"
  /// How many times the starter and opponent have provided a move
  public private(set) var turn: Int = 0
  private var playerIndex: Bool = true
  public private(set) var board: Board
  private var numericalBoard: Matrix<Int> {
    return Matrix(values: board.values.map({$0 != nil ? 1 : 0}), rows: board.rows, columns: board.columns)
  }
  /// The first player in a turn
  public let starter: Update
  /// The second player in a turn
  public let opponent: Update
  /// The player who would be asked for the next move
  public var player: Update {
    return playerIndex ? starter : opponent
  }
  /// The current game phase which is derived from turn
  public var phase: Phase {
    if turn == 0 {return .Restricted(playerIndex ? .Horizontal : .Vertical)}
    if turn <= 5 {return .Liberal}
    return .KnockOut
  }
  public var notify: ((_ status: Status) -> Void)?
  /// Initialize a new begriffix game with given players
  public init?(startLetters: [[Letter?]], starter: @escaping(Update), opponent: @escaping(Update)) {
    guard let startLetters = Board(values: startLetters) else {return nil}
    board = Board(repeating: nil, rows: 8, columns: 8)
    board[3..<5, 3..<5] = startLetters
    self.starter = starter
    self.opponent = opponent
  }
  public mutating func play() throws {
    var ended = false
    repeat {
      let cmd = player(self)
      switch cmd {
      case let .Write(word, place):
        try insert(word, at: place)
        notify?(.moved(cmd))
      case .GiveUp:
        ended = true
        notify?(.Ended)
      }
    } while !ended
  }
  /// Apply a move to the game
  public mutating func insert(_ word: Word, at place: Place) throws {
    guard isValid(word: word, for: place) else {throw MoveError.Word}
    playerIndex.toggle()
    if playerIndex {turn += 1}
    let area = place.area
    board[area] = Matrix(values: word, area: area)
  }
  /// Get the search pattern at a given place
  public func pattern(of place: Place) -> Pattern {
    return board[place.area].values
  }
  /// Indicates if a word fits a pattern
  public func isValid(word: Word, for pattern: Pattern) -> Bool {
    if word.count != pattern.count {return false}
    return zip(word, pattern).allSatisfy {$0.1 == nil ? true : $0.0 == $0.1}
  }
  /// Indicates if a word fits the pattern at a given place
  public func isValid(word: Word, for place: Place) -> Bool {
    return isValid(word: word, for: pattern(of: place))
  }
  /// Find every place where words with allowed direction and length could be written
  public func find() -> [Place]? {
    let direction: [Direction], min: Int
    switch phase {
    case .Restricted(let dir):
      min = 4
      direction = [dir]
    case .Liberal:
      min = 3
      direction = Direction.allCases
    case .KnockOut: return nil
    }
    var places = [Place]()
    for dir in direction {
      for count in stride(from: 8, through: min, by: -1) {
        places += find(direction: dir, count: count).map {Place(start: $0, direction: dir, count: count)}
      }
    }
    return places
  }
  /// Find every start point where words with given direction and length could be written
  public func find(direction: Direction, count: Int) -> [Point] {
    let k2 = direction.kernel(2)
    let k3 = direction.kernel(3)
    let f2 = numericalBoard.conv2(k2).extend(k2)
    let f3 = numericalBoard.conv2(k3).extend(k3).conv2(k2).dilate(k2)
    let w = direction.kernel(count)
    let w2 = f2.conv2(w)
    let w3 = f3.conv2(w)
    let w2_inv = w2.values.map {$0 >= 2 ? 1 : 0}
    let w3_inv = w3.values.map {$0 == 0 ? 1 : 0}
    let allowed = w2_inv*w3_inv
    let positions = allowed.enumerated().filter({$1 == 1}).map({(n, _) in w2.point(of: n)})
    if w2.count == count {return positions}
    return positions.filter { p in
      switch direction {
      case .Horizontal:
        if p.column > 0 && board[p.row, p.column-1] != nil {return false}
        let end = p.column+count
        if end < board.columns && board[p.row, end] != nil {return false}
      case .Vertical:
        if p.row > 0 && board[p.row-1, p.column] != nil {return false}
        let end = p.row+count
        if end < board.rows && board[end, p.column] != nil {return false}
      }
      return true
    }
  }
  /// Return the words crossing the given place after inserting a given word
  public func words(orthogonalTo place: Place, word: Word) -> [Word] {
    let area = place.area
    var board = self.board
    board[area] = Matrix(values: word, area: area)
    let values: [[Letter?]], around: Int
    switch place.direction {
    case .Horizontal:
      values = board.colwise(in: area.columns)
      around = place.start.row
    case .Vertical:
      values = board.rowwise(in: area.rows)
      around = place.start.column
    }
    return values.compactMap {
      let r = $0.indices(around: around, surround: nil)
      if r.count < 3 {return nil}
      let word = $0[r].compactMap {$0}
      return word
    }
  }
  /// Indicate if the given place is usable
  public func contains(place: Place) -> Bool {
    return find(direction: place.direction, count: place.count).contains(place.start)
  }
}

extension BidirectionalCollection where Element: Equatable {
  /// Returns the indices around a given index to return a slice that is surrounded by a given element
  func indices(around i: Index, surround: Element) -> Range<Index> {
    assert(indices.contains(i), "i out of bounds")
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
