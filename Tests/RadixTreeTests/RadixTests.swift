import XCTest
@testable import RadixTree

final class RadixTests: XCTestCase {
  let word = ""
  let range = 3...5
  let pattern = "????zh????"
  var dict: Set<String>?
  var radix: Radix?
  override func setUp() {
    if let dict = ScrabbleDict(lang: .german) {
      self.dict = dict.data
      let radix = Radix()
      for x in dict.data {
        radix.insert(x)
      }
      self.radix = radix
      print("built book")
    }
  }
  func testInsert() {
    let words = ["hallo", "halt", "halli", "hall"]
    insertHelper(words: words)
    insertHelper(words: words.reversed())
  }
  func testDict() {
  guard let radix = self.radix, let dict = self.dict else {return}
  let words = dict.prefix(5)
    measure {
      for w in words {
        if !radix.contains(w) {
          print(w)
          XCTAssert(false)
        }
      }
    }
  }
  func testDescending() {
    let radix = Radix()
    radix.insert("hallo")
    radix.insert("hall")
    XCTAssert(radix.contains("hall"))
    XCTAssert(radix.contains("hallo"))
  }
  func insertHelper(words: [String]) {
    let radix = Radix()
    for w in words {
      radix.insert(w)
    }
    for w in words {
      XCTAssert(radix.contains(w))
    }
  }
    static var allTests = [
       ("Test Insert", testInsert),
       ("test Dict", testDict),
       ("Test Descending", testDescending)
    ]
}
