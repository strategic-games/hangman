import XCTest
@testable import Utility

final class RadixTests: XCTestCase {
  let word = ""
  let range = 3...5
  let pattern = "????zh????"
  var dict: [[Unicode.Scalar]]?
  var radix: Radix?
  override func setUp() {
    let str = WordList.ScrabbleDict.load()
    dict = str?.unicodeScalars.split(separator: "\n").map {Array($0)}
    if let tmp = self.dict {
      let radix = Radix()
      for x in tmp {
        radix.insert(x)
      }
      self.radix = radix
    }
  }
  func testInsert() {
    let words = ["hallo", "halt", "halli", "hall"]
    insertHelper(words: words)
    insertHelper(words: words.reversed())
  }
  func testDict() {
  guard let radix = self.radix, let dict = self.dict else {return}
    let words = dict
    measure {
      for w in words {
        if !radix.contains(w) {
          print(w)
            XCTAssert(false)
            break
        }
      }
    }
  }
    func testAnagramm() {
        guard let radix = self.radix, let dict = self.dict else {return}
        let words = dict.map {Array($0.reversed())}
        var counter: Int = 0
        measure {
            for w in words {
                if radix.contains(w) {
                    XCTAssert(counter < 50000)
                    counter += 1
                }
            }
        }
    }
  func testDescending() {
    let radix = Radix()
    radix.insert("hallo")
    radix.insert("hall")
    XCTAssert(radix.contains("hall"), "hall not contained")
    XCTAssert(radix.contains("hallo"), "hallo not contained")
  }
    func testAtomar() {
        let radix = Radix()
        radix.insert("hallo")
        XCTAssertFalse(radix.contains("hall"))
    }
  func testRemove() {
    guard let radix = self.radix, let dict = self.dict else {return}
    for w in dict.prefix(10) {
      XCTAssert(radix.contains(w))
      radix.remove(w)
      XCTAssertFalse(radix.contains(w))
    }
    _ = radix.contains("oktaviert")
  }
  func testMatch() {
    guard let radix = self.radix else {return}
    measure {
      _ = radix.search(pattern: "???zh???")
    }
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
