struct Move {
  typealias Board = Matrix<Character?>
  enum Direction {
    case Horizontal, Vertical
    func kernel(_ count: Int) -> Matrix<Int> {
      let size: Dimensions
      switch self {
      case .Horizontal: size = Dimensions(1, count)
      case .Vertical: size = Dimensions(count, 1)
      }
      return Matrix(repeating: 1, size: size)
    }
  }
  var start: Position
  var direction: Direction
  var count: Int {
    didSet {word = ""}
  }
  var word: String {
    didSet {count = word.count}
  }
  init(start: Position = Position(0, 0), direction: Direction, word: String) {
    self.start = start
    self.direction = direction
    self.word = word
    self.count = word.count
  }
  init(start: Position = Position(0, 0), direction: Direction, count: Int) {
    self.start = start
    self.direction = direction
    self.count = count
    self.word = ""
  }
  func positions() -> [Position] {
    let r = 0..<count
    switch direction {
    case .Horizontal:
      return r.map {Position(start.i, start.j+$0)}
    case .Vertical:
      return r.map {Position(start.i+$0, start.j)}
    }
  }
  func write(on board: inout Board) {
    for (p, c) in zip(positions(), word) {
      board[p] = c
    }
  }
  func pattern(_ board: Board) -> String {
    if count == 0 {return ""}
    let positions = self.positions()
    var pattern = ""
    for p in positions {
      pattern.append(board[p] ?? "?")
    }
    return pattern
  }
  func kernel() -> Matrix<Int> {
    return direction.kernel(self.count)
  }
}
