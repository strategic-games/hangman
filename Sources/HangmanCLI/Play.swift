import Foundation
import SwiftCLI
import Hangman

class PlayCommand: Command {
  struct Record: Codable {
    let game: Int
    let turn: Int
    let word: String
    let sum: Int
  }
  let name = "play"
  let input = Key<String>("-i", "--input", description: "Path to a json file containing a radix serialization")
  let auto = Flag("-a", "--auto")
  let times = Key<Int>("-n", "--num-of-times")
  func execute() throws {
    let file = URL(fileURLWithPath: input.value ?? "Resources/dictionaries/german.txt")
    let text = try String(contentsOf: file)
    let radix = Radix()
    radix.insert(text: text)
    stdout <<< "radix created"
    let startLetters: [[Character]] = [["l","a"],["e","r"]]
    if auto.value == true {
      let times = self.times.value ?? 1
      let starter = RandomPlayer(vocabulary: radix)
      let game = Begriffix(startLetters: startLetters, starter: starter, opponent: starter)
      var records = [Record]()
      records.reserveCapacity(5*times)
      for n in 0..<times {
        stdout <<< "starting game \(n)"
        let moves: [Begriffix.Move] = game.map {$0.1}
        records += moves.enumerated().map { (turn, move) in
          let wordSum = move.places?.map({(_, words) in words.count}).sum() ?? 0
          return Record(game: n, turn: turn, word: move.word, sum: wordSum)
        }
      }
      stdout <<< "records created"
      let jsonEncoder = JSONEncoder()
      let jsonData = try jsonEncoder.encode(records)
      stdout.writeData(jsonData)
    } else {
      let game = Begriffix(startLetters: startLetters, starter: RandomPlayer(vocabulary: radix), opponent: HumanPlayer())
      for (state, _) in game {
        stdout <<< state.board.description
      }
    }
  }
}
