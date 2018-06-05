import XCTest
@testable import hangman

final class hangmanTests: XCTestCase {
  let word = ""
  let range = 3...5
  let pattern = "????zh????"
  var dict: Set<String>?
  var hangman: Hangman?
  override func setUp() {
    if let dict = ScrabbleDict(lang: .german) {
      self.dict = dict.data
      hangman = Hangman(dict.data)
    }
  }
  /*
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
  func testWorstCase() {
    let str = "??????????"
    measure{
      _ = hangman?.match(str)
    }
  }
 */
  func testMatch() {
    /*
    measure{
      _ = hangman?.search(range: 10...10)
    }
 */
    let result = hangman?.search(range: 10...10)
    print(result?.count)
  }

    static var allTests = [
      /*
      ("Test Prefix", testPrefix),
        ("Test Range", testRange),
        ("Test worst case", testWorstCase),
 */
      ("Test Match", testMatch),
    ]
}
