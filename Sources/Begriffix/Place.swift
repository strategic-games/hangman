/// A place on a game board, where a word can be written
public struct Place: Hashable {
  /// The 2D position where the word starts
  let start: Position
  /// The writing direction
  let direction: Direction
  /// The word length
  let count: Int
  /// Return all positions that this place would occupy on a board
  func positions() -> [Position] {
    let r = 0..<count
    switch direction {
    case .Horizontal:
      return r.map {Position(start.i, start.j+$0)}
    case .Vertical:
      return r.map {Position(start.i+$0, start.j)}
    }
  }
  /// Return a matrix according to this place in direction and length
  func kernel() -> Matrix<Int> {
    return direction.kernel(self.count)
  }
  /// Return the range of lines that would be crossed by this place
  func lines() -> (Range<Int>, Int) {
    let start: Int, around: Int
    switch direction {
    case .Horizontal:
      start = self.start.j
      around = self.start.i
    case .Vertical:
      start = self.start.i
      around = self.start.j
    }
    return (start..<start+count, around)
  }
}
