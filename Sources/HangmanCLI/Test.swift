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
    let json = "test.json"
    guard FileManager.default.isReadableFile(atPath: json) else {
      stderr <<< "input file not accessible"
      return
    }
    guard let jsonData = ReadStream(path: json)?.readData() else {
      stderr <<< "input file couldn't be opened"
      return
    }
    let jsonDecoder = JSONDecoder()
    let test = try jsonDecoder.decode(Radix.self, from: jsonData)
    print(test)
  }
}
