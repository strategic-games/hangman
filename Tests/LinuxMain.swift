import XCTest

import hangmanTests

var tests = [XCTestCaseEntry]()
tests += hangmanTests.allTests()
XCTMain(tests)