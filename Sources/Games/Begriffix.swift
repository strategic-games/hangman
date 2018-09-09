import Utility

/// A begriffix game
public struct Begriffix: DyadicGame {
  /// The type of a letter, can be written at one board position
  public typealias Letter = Unicode.Scalar
  /// The type of a word which is a sequence of letters
  public typealias Word = [Letter]
  /// A sequence of optional letters, nil means that any letter can be used there
  public typealias Pattern = [Letter?]
  public typealias Board = Matrix<Letter?>
  /// Errors that can happen when a move is inserted
  public enum MoveError: Error {
    /// The board does not contain this place
    case Place
    /// The word does not fit at the intended place
    case Word
  }
  /// The writing direction
  public enum Direction: CaseIterable {
    /// From left to right
    case Horizontal
    /// from top to bottom
    case Vertical
    /// Return a kernel according to this direction and a given length
    func kernel(_ count: Int) -> Matrix<Int> {
      switch self {
      case .Horizontal: return Matrix(repeating: 1, rows: 1, columns: count)
      case .Vertical: return Matrix(repeating: 1, rows: count, columns: 1)
      }
    }
  }
  /// A place where a word could be written
  public struct Place: Hashable {
    /// The position of the first letter
    public let start: Point
    /// The writing direction
    public let direction: Direction
    /// The word length
    public let count: Int
    /// Initialize a new place
    public init(start: Point, direction: Direction, count: Int) {
      self.start = start
      self.direction = direction
      self.count = count
    }
    /// An area representation of the place for inserting into matrices
    public var area: Area {
      switch direction {
      case .Horizontal:
        return Area(rows: start.row..<(start.row+1), columns: start.column..<(start.column+count))
      case .Vertical:
        return Area(rows: start.row..<(start.row+count), columns: start.column..<(start.column+1))
      }
    }
    /// A matrix filled with 1 according to the area
    var kernel: Matrix<Int> {return direction.kernel(count)}
  }
  /// A begriffix move
  public struct Move {
    /// Where the word should be written
    public let place: Place
    /// The word to write in this move
    public let word: Word
    /// The collection which the move has been selected from
    public let places: [Place: [Word]]?
    /// Initialize a move
    public init(place: Place, word: Word, places: [Place: [Word]]? = nil) {
      self.place = place
      self.word = word
      self.places = places
    }
  }
  /// General progress states of a game
  public enum State {
    /// The game has a freshly setup game board
    case Ready
    /// Some changes were made to the board
    case Playing
    /// The game has ended because a player couldn't prrovide a move
    case Ended
    /// An error occured while a move was applied
    case Crashed(Error)
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
  /// Some human-generated start letters
  public static let name = "Begriffix"
  public static let startLetters: [StaticString] = ["laer", "jaul", "kiod", "osni", "brau", "teoc", "ziaf", "prau", "muah", "wuag", "roed", "kanu", "giut", "fued", "ingo", "ehmo", "pois", "biel", "ormi"]
  public private(set) var board: Matrix<Letter?>
  private var numericalBoard: Matrix<Int> {
    return Matrix(values: board.values.map({$0 != nil ? 1 : 0}), rows: board.rows, columns: board.columns)
  }
  /// The first player in a turn
  public let starter: BegriffixPlayer
  /// The second player in a turn
  public let opponent: BegriffixPlayer
  /// How many times the starter and opponent have provided a move
  public private(set) var turn: Int = 0
  private var playerIndex: Bool = true
  /// The player who would be asked for the next move
  public var player: BegriffixPlayer {
    return playerIndex ? starter : opponent
  }
  /// The playing state of the game, is ready by default
  public private(set) var state: State = .Ready
  /// The current game phase which is derived from turn
  public var phase: Phase {
    if turn == 0 {return .Restricted(playerIndex ? .Horizontal : .Vertical)}
    if turn <= 5 {return .Liberal}
    return .KnockOut
  }
  /// Initialize a new begriffix game with given players
  public init?(startLetters: [[Letter?]], starter: BegriffixPlayer, opponent: BegriffixPlayer) {
    guard let startLetters = Board(values: startLetters) else {return nil}
    board = Board(repeating: nil, rows: 8, columns: 8)
    board[3..<5, 3..<5] = startLetters
    self.starter = starter
    self.opponent = opponent
  }
  /// Initialize a new game with given players and randomly selected start letters
  public init?(starter: BegriffixPlayer, opponent: BegriffixPlayer) {
    guard let letters = Begriffix.startLetters.randomElement() else {return nil}
    board = Board(repeating: nil, rows: 8, columns: 8)
    let subboard: Board = Board(values: Array(letters.description.unicodeScalars), rows: 2, columns: 2)
    board[3..<5, 3..<5] = subboard
    self.starter = starter
    self.opponent = opponent
  }
  /// Advance the game for one move
  public mutating func next() -> (Begriffix, Move)? {
    guard let move = player.move(self) else {
      state = .Ended
      return nil
    }
    do {
      try insert(move)
    } catch {
      state = .Crashed(error)
      return nil
    }
    return (self, move)
  }
  /// Apply a move to the game
  public mutating func insert(_ move: Move) throws {
    guard isValid(word: move.word, for: move.place) else {throw MoveError.Word}
    playerIndex.toggle()
    if playerIndex {turn += 1}
    let area = move.place.area
    board[area] = Matrix(values: move.word, area: area)
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

extension Matrix: LosslessStringConvertible where Element == Unicode.Scalar? {
  /// A textual 2D representation with dot for empty fields
  public var description: String {
    return self.rowwise().map({ (row: [Element]) -> String in
      return String(String.UnicodeScalarView(row.compactMap {$0 == nil ? "." : $0}))
      })
      .joined(separator: "\n")
  }
  /// Initialize from 2D description
  public init?(_ description: String) {
    self.init(values: description.unicodeScalars.map({$0 == "." ? nil : $0}).split(separator: "\n").map {Array($0)})
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
