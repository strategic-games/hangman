/// A begriffix game
struct Begriffix: BoardGame {
  struct Options: BoardGameOptions {
    let boardSize = Dimensions(8)
    let players = 2
    let turns = 6
  }
  let options: Options
  var placeFinder: PlaceFinder
  var board: Matrix<Character?>
  var numBoard: Matrix<Int> {
    let nums: [Int] = board.map {$0 == nil ? 0 : 1}
    return Matrix(nums, size: board.size)
  }
  var boolBoard: Matrix<Bool> {
   let bools: [Bool] = board.map {$0 == nil ? false : true}
   return Matrix(bools, size: board.size)
  }
  init(_ options: Options) {
    self.options = options
    board = Matrix(repeating: nil, size: options.boardSize)
    placeFinder = PlaceFinder(board.size)
  }
  init() {
    self.init(Options())
  }
  mutating func setup() {
    let startLetters: [Character?] = ["z", "h", "n", "r"]
    board[Position(3, 3), Dimensions(2, 2)] = startLetters
  }
  func play() {
    for p in self {
  move(p)
  }
  }
  func finalize() {
    
  }
  func move(_ p: (turn: Int, player: Int)) {
    let moveOpts: PlaceOptions
    if p.turn > 0 {
      moveOpts = .all
    } else if p.player == 0 {
      moveOpts = .horizontal
    } else {
      moveOpts = .vertical
    }
    let result = placeFinder.scan(numBoard, options: moveOpts)
  }
}

extension Begriffix: Sequence {
  typealias Iterator = BoardGameIterator
func makeIterator() -> Iterator {
    return Iterator(options)
  }
}
