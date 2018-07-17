/// The state of a Begriffix game
public struct State {
  /// The value type that the board accepts
  public typealias Entity = Character?
  /// The type of the board container that holds the entered values
  public typealias Board = Matrix<Entity>
  /// game phases depending on the progress
  public enum Phase {
    /// Players must write words with at least four characters, player 0 must write horizontally, and player 1 must write vertically
    case Restricted
    /// Any words and directions are allowed
    case Liberal
    /// not yet implemented
    case KnockOut
  }
  /// An option set that determines which words are acceptable
  struct WriteOptions: OptionSet {
    let rawValue: Int
    /// Words may be written horizontally
    static let horizontal = WriteOptions(rawValue: 1<<0)
    /// Words may be written vertically
    static let vertical = WriteOptions(rawValue: 1<<1)
    /// Words may consist of at least three letters (four otherwise)
    static let includeThree = WriteOptions(rawValue: 1<<2)
    /// Any direction is allowed and words may be short (3 letters)
    static let all: WriteOptions = [.horizontal, .vertical, .includeThree]
  }
  /// Letters that are written in the center of a board
  static let startLetters = Board([["z", "h"], ["e", "n"]])
  /// Create a new starting board
  static func createStartBoard() -> Board {
    var board = Board(repeating: nil, size: Dimensions(8, 8))
    board[Position(3, 3), Dimensions(2, 2)] = State.startLetters
    return board
  }
  /// The board holding the written letters
  public let board: Board
  /// The board as numeric representation (filled = 1, empty = 0)
  var numericalBoard: Matrix<Int> {
    return board.map2 {$0 != nil ? 1 : 0}
  }
  /// The turn counter
  public let turn: Int
  /// The current player who has to deal with this state
  public let player: Bool
  /// Is this an untouched game state?
  var isPristine: Bool {
    return turn == 0 && player == true
  }
  /// The current game phase which is derived from turn
  var phase: Phase {
    if turn == 0 {return .Restricted}
    if turn <= 5 {return .Liberal}
    else {return .KnockOut}
  }
  /// The possible writing options, derived from phase and player
  var options: WriteOptions {
    switch phase {
    case .Restricted:
      if player == true {
        return .horizontal
      } else {
        return .vertical
      }
    default: return .all
    }
  }
  /// Initialize a pristine game state
  init() {
    turn = 0
    player = true
    self.board = State.createStartBoard()
  }
  /// Initialize a new state from given properties
  init(turn: Int, player: Bool, board: Board) {
    self.turn = turn
    self.player = player
    self.board = board
  }
  /// Initialize a new state based on a given state by merging a user action
  init(base: State, move: Move) {
    player = !base.player
    turn = player ? base.turn+1 : base.turn
    var board = base.board
    board[move.start, move.direction, move.count] = [Character](move.word)
    self.board = board
  }
  /// Create a new state from a given base state and a player action
  static func +(state: State, move: Move) -> State {
    return State(base: state, move: move)
  }
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
    let p = allowed.enumerated().filter({$1 == 1}).map {(n, _) in size.position(n)}
    return p.filter {noCollisions(p: $0, dir: direction, count: count)}
  }
  func noCollisions(p: Position, dir: Direction, count: Int) -> Bool {
    switch dir {
    case .Horizontal:
      if count == board.size.n {return true}
      if p.j > 0 && board[Position(p.i, p.j-1)] != nil {return false}
      let end = p.j+count
      if end < board.size.n && board[Position(p.i, end)] != nil {return false}
    case .Vertical:
      if count == board.size.m {return true}
      if p.i > 0 && board[Position(p.i-1, p.j)] != nil {return false}
      let end = p.i+count
      if end < board.size.m && board[Position(end, p.j)] != nil {return false}
    }
    return true
  }
  /// Return the words written on the board
  func words(_ dir: Direction, lines: Range<Int>? = nil) -> [[String]] {
    switch dir {
    case .Horizontal:
      let lines = lines ?? 0..<board.size.m
      return lines.map({board[row: $0].words()})
    case .Vertical:
      let lines = lines ?? 0..<board.size.n
      return lines.map({board[column: $0].words()})
    }
  }
}
