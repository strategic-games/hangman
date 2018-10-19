import XCTest
@testable import Utility

final class RadixTests: XCTestCase {
  let shorter = "Rassel"
  let longer = "Rasselbande"
  let secondLonger = "Rasseln"
  let diverging = "Rassentheorie"
  func testWordsShouldNotExistBeforeInsert() {
    let radix = Radix()
    words.forEach {XCTAssertFalse(radix.contains($0))}
  }
  func testPrefixesShouldNotBeWords() {
    let radix = Radix()
    radix.insert(longer)
    XCTAssert(radix.contains(longer))
    XCTAssertFalse(radix.contains(shorter))
  }
  func testWordsShouldExistAfterInsertAndNotAfterRemoving() {
    let radix = Radix()
    words.forEach { word in
      radix.insert(word)
      XCTAssert(radix.contains(word), "word not found after inserting")
      radix.remove(word)
      XCTAssertFalse(radix.contains(word), "word found after removing")
    }
  }
  func testShorterWordExistsAfterInsertingLonger() {
    let radix = Radix()
    radix.insert(shorter)
    XCTAssert(radix.contains(shorter), "shorter word not found before inserting longer word")
    radix.insert(longer)
    XCTAssert(radix.contains(shorter), "shorter word not found after inserting longer word")
    XCTAssert(radix.contains(longer), "longer word not found")
  }
  func testShorterExistsAfterInsertingTwoLonger() {
    let radix = Radix()
    radix.insert(shorter)
    radix.insert(longer)
    radix.insert(secondLonger)
    XCTAssert(radix.contains(shorter), "shorter word not found after inserting longer word")
    XCTAssert(radix.contains(longer), "longer word not found")
    XCTAssert(radix.contains(secondLonger), "longer word not found")
  }
  func testLongerWordExistsAfterRemovingShorter() {
    let radix = Radix()
    radix.insert(shorter)
    radix.insert(longer)
    XCTAssert(radix.contains(shorter), "shorter word not found after inserting longer")
    XCTAssert(radix.contains(longer))
    radix.remove(shorter)
    XCTAssertFalse(radix.contains(shorter), "shorter found despite removing")
    XCTAssert(radix.contains(longer), "longer not found after removing shorter")
  }
  func testInsertShorterAfterLongerWord() {
    let radix = Radix()
    radix.insert(longer)
    radix.insert(shorter)
    XCTAssert(radix.contains(shorter))
    XCTAssert(radix.contains(longer))
  }
  func testInsertedWordsExistAfterInsertingDivergentWords() {
    let radix = Radix()
    radix.insert(shorter)
    radix.insert(diverging)
    XCTAssert(radix.contains(shorter))
    XCTAssert(radix.contains(diverging))
  }
  func testSearch() {
    let radix = Radix()
    let words = [shorter, longer, secondLonger]
    words.forEach {radix.insert($0)}
    let found: [String] = radix.search()
    XCTAssertEqual(words.count, found.count)
    words.forEach {XCTAssert(found.contains($0))}
  }
  func testCollectionWord() {
    let x: [Character?] = [nil, "x", "y", "z", nil]
    XCTAssertEqual(x.indices(around: 2, surround: nil), 1..<4)
  }
}
