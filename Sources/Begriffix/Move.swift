public struct Move: Hashable {
  let place: Place
  let word: String
  let sum: Int
  func positions() -> [Position] {
    return place.positions()
  }
  func kernel() -> Matrix<Int> {
    return place.kernel()
  }
  /// Return the range of lines that would be crossed by this move
  func lines() -> (Range<Int>, Int) {
    return place.lines()
  }
}
