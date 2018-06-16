import XCTest

import BoardGamesTests
import HangManTests

var tests = [XCTestCaseEntry]()
tests += BoardGamesTests.__allTests()
tests += HangManTests.__allTests()

XCTMain(tests)
