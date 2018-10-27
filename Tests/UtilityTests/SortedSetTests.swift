import XCTest
@testable import Utility

let words = [
  "AA", "AACHENER", "AACHENERIN", "AACHENERINNEN", "AACHENERN",
  "AACHENERS", "AAL", "AALE", "AALEN", "AALEND"
]

class SortedSetTests: XCTestCase {

  override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() {
      var set = SortedSet<String>()
      for word in words.prefix(10) {
        XCTAssertFalse(set.contains(word))
        set.insert(word)
        XCTAssert(set.contains(word))
      }
    }
  func testRemove() {
    var set = SortedSet<String>(words)
    for word in words {
      XCTAssert(set.contains(word))
      set.remove(word)
      XCTAssertFalse(set.contains(word))
    }
  }
}
