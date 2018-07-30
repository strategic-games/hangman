//
//  SortedSetTests.swift
//  RadixTreeTests
//
//  Created by Tamara Cook on 29.06.18.
//

import XCTest
@testable import Hangman

class SortedSetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() {
      var x = SortedSet<String>()
      guard let dict = DictHelper.loadData("german") else {return}
      for w in dict.prefix(10) {
        XCTAssertFalse(x.contains(w))
        x.insert(w)
        XCTAssert(x.contains(w))
      }
    }
  func testRemove() {
    guard let dict = DictHelper.loadData("german") else {return}
    let words = dict.prefix(10)
    var x = SortedSet<String>(words)
    for w in words {
      XCTAssert(x.contains(w))
      x.remove(w)
      XCTAssertFalse(x.contains(w))
    }
  }
}
