import Foundation
import SwiftCLI
import Utility
import Games

class SwingCommand: Command {
  typealias Word = [Unicode.Scalar]
  struct Record: Codable {
    let startLetters: String
    let words: Int
  }
  let name = "swing"
  let shortDescription = "find a stable dictionary size which survives the given number of game turns"
  func execute() throws {
    let data = try loadDict()
    let radix = Radix()
    data.forEach {radix.insert($0)}
    let player = RandomPlayer(vocabulary: radix)
    let records = Begriffix.startLetters
      .compactMap {String(describing: $0)}
      .map { (s: String) -> Record in
        let x = Array(s.unicodeScalars)
        let sl = [[x[0], x[1]], [x[2], x[3]]]
        let game = Begriffix(startLetters: sl, starter: player, opponent: player)!
        let move = player.move(game)
        let count = move?.places?.values.map({$0.count}).sum() ?? 0
        return Record(startLetters: s, words: count)
    }
    try writeJson(records)
  }
  func play(_ radix: Radix) throws -> [Int] {
    var moveCount = [Int]()
    let player = RandomPlayer(vocabulary: radix)
    for _ in 1...100 {
      guard let game = Begriffix(starter: player, opponent: player) else {return moveCount}
      let moves = game.map {$0}
      moveCount.append(moves.count)
    }
    return moveCount
  }
  func loadDict() throws -> [Word] {
    let txt = URL(fileURLWithPath: "Resources/dictionaries/derewo-v-100000t-2009-04-30-0.1")
    let content = try String(contentsOf: txt).lowercased()
    return content.unicodeScalars.split(separator: "\n")
      .drop(while: {$0.first == "#"})
      .compactMap { (line) -> Word? in
        let splitted = line.split(separator: " ")
        guard splitted.count == 2 else {return nil}
        return Array(splitted[0])
    }
  }
  func writeJson(_ records: [Record]) throws {
    let jsonEncoder = JSONEncoder()
    let jsonData = try jsonEncoder.encode(records)
    let json = URL(fileURLWithPath: "records.json")
    try jsonData.write(to: json)
  }
}
