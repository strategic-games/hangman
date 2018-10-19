import XCTest
@testable import Utility

let words = ["AA", "AACHENER", "AACHENERIN", "AACHENERINNEN", "AACHENERN", "AACHENERS", "AAL", "AALE", "AALEN", "AALEND"]

class SortedSetTests: XCTestCase {

  override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() {
      var x = SortedSet<String>()
      for w in words.prefix(10) {
        XCTAssertFalse(x.contains(w))
        x.insert(w)
        XCTAssert(x.contains(w))
      }
    }
  func testRemove() {
    var x = SortedSet<String>(words)
    for w in words {
      XCTAssert(x.contains(w))
      x.remove(w)
      XCTAssertFalse(x.contains(w))
    }
  }
}
