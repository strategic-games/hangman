import XCTest

import BoardGamesTests
import RadixTreeTests
import HangManTests

var tests = [XCTestCaseEntry]()
tests += BoardGamesTests.__allTests()
tests += RadixTreeTests.__allTests()
tests += HangManTests.__allTests()

XCTMain(tests)
