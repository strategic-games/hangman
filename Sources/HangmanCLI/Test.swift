import Foundation
import SwiftCLI
import Hangman

struct Test: Codable, CustomStringConvertible {
  let name: String
  let description: String
}

class TestCommand: Command {
  let name = "test"
  func execute() throws {
    let radix = Radix()
    radix.insert("hallo")
  }
}
