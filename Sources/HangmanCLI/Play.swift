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
  let output = Key<String>("-o", "--output", description: "Path to the file where the results schould be written to")
  let auto = Flag("-a", "--auto")
  let times = Key<Int>("-n", "--num-of-times")
  func execute() throws {
    let file = URL(fileURLWithPath: input.value ?? "Resources/dictionaries/german.txt")
    let content = try String(contentsOf: file).lowercased()
    let radix = Radix(text: content)
    let startLetters: [[Unicode.Scalar]] = [["l", "a"], ["e", "r"]]
    if auto.value == true {
      let times = self.times.value ?? 1
      let starter = RandomPlayer(vocabulary: radix)
      let game = Begriffix(startLetters: startLetters, starter: starter, opponent: starter)
      var records = [Record]()
      records.reserveCapacity(5*times)
      for n in 0..<times {
        print("play \(n)")
        let moves: [Begriffix.Move] = game.map {$0.1}
        records += moves.enumerated().map { (turn, move) in
          let wordSum = move.places?.map({(_, words) in words.count}).sum() ?? 0
          return Record(game: n, turn: turn, word: move.word.description, sum: wordSum)
        }
      }
      if let outValue = output.value {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(records)
        let out = URL(fileURLWithPath: outValue)
        try jsonData.write(to: out)
      } else {
        //stdout.writeData(jsonData)
      }
    } else {
      let game = Begriffix(startLetters: startLetters, starter: RandomPlayer(vocabulary: radix), opponent: HumanPlayer())
      for (state, _) in game {
        stdout <<< state.board.map2({if let l = $0 {return Character(l)} else {return nil}}).description
      }
    }
  }
}
