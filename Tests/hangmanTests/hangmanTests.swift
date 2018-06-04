import XCTest
@testable import hangman

final class hangmanTests: XCTestCase {
  let word = "zug"
  let range = 3...5
  let pattern = "???zh???"
  var hangman: Hangman?
  override func setUp() {
    if let dict = ScrabbleDict(lang: .german) {
      hangman = Hangman(dict.data)
    }
  }
  func testPrefix() {
    measure{
      _ = hangman?.search(prefix: word)
    }
  }
    func testRange() {
      measure{
        _ = hangman?.search(range: range)
      }
  }
  func testMatch() {
    measure{
      _ = hangman?.match(pattern)
    }
  }
  func testWorstCase() {
    let str = "???????????????"
    measure{
      _ = hangman?.match(str)
    }
  }

    static var allTests = [
        ("Test Prefix", testPrefix),
        ("Test Range", testRange),
        ("Test Match", testMatch),
        ("Test worst case", testWorstCase)
    ]
}
