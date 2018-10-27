import Utility

/// A begriffix game
public struct Begriffix: Game&BoardGame&Trackable&Sequence&IteratorProtocol {
  /// The type of a letter, can be written at one board position
  public typealias Letter = Unicode.Scalar
  /// The type of a word which is a sequence of letters
  public typealias Word = [Letter]
  public typealias Field = Letter?
  /// A sequence of optional letters, nil means that any letter can be used there
  public typealias Pattern = [Field]
  public typealias Board = Matrix<Field>
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
  /// Errors that can occur when a move is inserted
  public enum MoveError: Error {
    /// The board does not contain this place
    case invalidPlace
    /// The word does not fit at the intended place
    case patternMismatch
  }
  /// phases of a game which is currently playing
  public enum Phase {
    /// Players must write words with at least four letters,
    /// starting player must write horizontally, and opponent vertically
    case restricted(Direction)
    /// Any words and directions are allowed
    case liberal
    /// not yet implemented
    case knockOut
  }
  public static let name = "Begriffix"
  /// How many times the starter and opponent have provided a move
  public private(set) var turn: Int = 0
  private var playerIndex: Bool = true
  public private(set) var board: Board
  public func character(_ field: Field) -> Character {
    return field != nil ? Character(field!) : "."
  }
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
    if turn == 0 {return .restricted(playerIndex ? .horizontal : .vertical)}
    if turn <= 5 {return .liberal}
    return .knockOut
  }
  public var notify: Notify
  /// Initialize a new begriffix game with given board and players
  public init(board: Board, starter: @escaping(Update), opponent: @escaping(Update)) {
    self.board = board
    self.starter = starter
    self.opponent = opponent
  }
  /// Initialize a new begriffix game with start letters as 2*2 fields board
  public init(startLetters: Board, starter: @escaping(Update), opponent: @escaping(Update)) {
    var board = Board(repeating: nil, rows: 8, columns: 8)
    board[3..<5, 3..<5] = startLetters
    self.init(board: board, starter: starter, opponent: opponent)
  }
  /// Initialize a new begriffix game with start letters as array of four field values
  public init(startLetters: [Field], starter: @escaping(Update), opponent: @escaping(Update)) {
    precondition(startLetters.count == 4, "Need exactly four start letters")
    let startLetters = Board(values: startLetters, rows: 2, columns: 2)
    self.init(startLetters: startLetters, starter: starter, opponent: opponent)
  }
  /// Initialize a new begriffix game with start letters as 2*2 nested array
  public init?(startLetters: [[Letter]], starter: @escaping(Update), opponent: @escaping(Update)) {
    guard let startLetters = Board(values: startLetters) else {return nil}
    self.init(startLetters: startLetters, starter: starter, opponent: opponent)
  }
  /// Initialize a new begriffix game with start letters as string with four characters
  public init(startLetters: String, starter: @escaping(Update), opponent: @escaping(Update)) {
    let fields = Array(startLetters.unicodeScalars)
    self.init(startLetters: fields, starter: starter, opponent: opponent)
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
  /// Apply a move to the game
  public mutating func insert(_ move: Move) throws {
    guard isValid(move) else {throw MoveError.patternMismatch}
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
    guard word.count == pattern.count else {return false}
    return word.match(pattern: pattern)
  }
  /// Indicates if a word fits the pattern at a given place
  public func isValid(_ move: Move) -> Bool {
    return isValid(word: move.word, for: pattern(of: move.place))
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
    case .knockOut: return nil
    }
    var places = [Place]()
    for dir in direction {
      // stride(from: 8, through: min, by: -1)
      for count in min...8 {
        places += find(direction: dir, count: count).map {Place(start: $0, direction: dir, count: count)}
      }
    }
    return places
  }
  /// Find every start point where words with given direction and length could be written
  public func find(direction: Direction, count: Int) -> [Point] {
    let kern2 = direction.kernel(2)
    let kern3 = direction.kernel(3)
    let found2 = numericalBoard.conv2(kern2).extend(kern2)
    let found3 = numericalBoard.conv2(kern3).extend(kern3).conv2(kern2).dilate(kern2)
    let kernWord = direction.kernel(count)
    let word2 = found2.conv2(kernWord)
    let word3 = found3.conv2(kernWord)
    let word2inv = word2.values.map {$0 >= 2 ? 1 : 0}
    let word3inv = word3.values.map {$0 == 0 ? 1 : 0}
    let allowed = word2inv*word3inv
    let positions = allowed.enumerated()
      .filter {$1 == 1}
      .map { word2.point(of: $0.0)}
    if word2.count == count {return positions}
    return positions.filter { position in
      switch direction {
      case .horizontal:
        if position.column > 0 && board[position.row, position.column-1] != nil {return false}
        let end = position.column+count
        if end < board.columns && board[position.row, end] != nil {return false}
      case .vertical:
        if position.row > 0 && board[position.row-1, position.column] != nil {return false}
        let end = position.row+count
        if end < board.rows && board[end, position.column] != nil {return false}
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
    case .horizontal:
      values = board.colwise(in: area.columns)
      around = place.start.row
    case .vertical:
      values = board.rowwise(in: area.rows)
      around = place.start.column
    }
    return values.compactMap {Begriffix.word(in: $0, around: around)}
  }
  /// Extracts a word from a pattern around a given position
  ///
  /// - Parameters:
  ///   - line: A pattern, mostly a board row or column
  ///   - index: The position around which to search for letters.
  /// - Returns: If the element at the given position is part of a word with at least three letters, this word is returned, nil otherwise.
  public static func word(in line: Pattern, around index: Pattern.Index) -> Word? {
    assert(line.indices.contains(index), "index out of bounds")
    var start = index, end = index
    for next in stride(from: start, through: line.startIndex, by: -1) {
      if line[next] == nil {break}
      start = next
    }
    for next in end..<line.endIndex {
      if line[next] == nil {break}
      end = next
    }
    let range = start...end
    if range.count < 3 {return nil}
    let word = line[range].compactMap {$0}
    return word
  }
  /// Indicate if the given place is usable
  public func contains(_ place: Place) -> Bool {
    return find(direction: place.direction, count: place.count).contains(place.start)
  }
}
