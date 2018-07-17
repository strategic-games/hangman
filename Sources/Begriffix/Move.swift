public struct Move {
  let start: Position
  let direction: Direction
  let word: String
  let sum: Int
  var count: Int {return word.count}
  func positions() -> [Position] {
    let r = 0..<count
    switch direction {
    case .Horizontal:
      return r.map {Position(start.i, start.j+$0)}
    case .Vertical:
      return r.map {Position(start.i+$0, start.j)}
    }
  }
  func kernel() -> Matrix<Int> {
    return direction.kernel(self.count)
  }
  /// Return the range of lines that would be crossed by this move
  func lines() -> Range<Int> {
    let start: Int
    switch direction {
    case .Horizontal: start = self.start.j
    case .Vertical: start = self.start.i
    }
    return start..<start+word.count
  }
}
