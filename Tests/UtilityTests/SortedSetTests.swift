//
//  SortedSetTests.swift
//  RadixTreeTests
//
//  Created by Tamara Cook on 29.06.18.
//

import XCTest
@testable import Utility

class SortedSetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() {
      var x = SortedSet<String>()
      let dict = WordList.ScrabbleDict.words()
      for w in dict.prefix(10) {
        let stringValue = String(String.UnicodeScalarView(w))
        XCTAssertFalse(x.contains(String(String.UnicodeScalarView(w))))
        x.insert(stringValue)
        XCTAssert(x.contains(stringValue))
      }
    }
  func testRemove() {
    let dict = WordList.ScrabbleDict.words()
    let words = dict.prefix(10).map {String(String.UnicodeScalarView($0))}
    var x = SortedSet<String>(words)
    for w in words {
      XCTAssert(x.contains(w))
      x.remove(w)
      XCTAssertFalse(x.contains(w))
    }
  }
}
