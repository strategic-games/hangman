import Foundation
import SwiftCLI
import Utility
import Games

struct BegriffixSimulation: Codable {
  typealias Game = Begriffix
  typealias Info = DefaultInfo<Begriffix>
  struct Condition: Codable {
    enum WordMode: String, Codable {
      case Prefix, Random, Suffix, Full
    }
    struct Subject: Hashable, Codable {
      let wordList: WordList
      let wordCount: Int
      let wordMode: WordMode
    }
    let startLetters: Begriffix.Word
    let starter: Subject
    let opponent: Subject?
    let trials: Int
  }
  struct Record: Codable {
    let move: Begriffix.Move
    let pattern: Begriffix.Pattern
    let places: Int
    let words: Int
  }
  var info: DefaultInfo<Begriffix>
  var conditions: [Condition]
  var result: [[[Record]]]?
  mutating func process() {
    result = conditions.map {process($0)}
  }
  func process(_ condition: Condition) -> [[Record]] {
    let starter = createSubject(from: condition.starter)
    let game: Begriffix
    if let opponentSubject = condition.opponent {
      let opponent = createSubject(from: opponentSubject)
      game = Begriffix(startLetters: condition.startLetters, starter: starter.move, opponent: opponent.move)
    } else {
      game = Begriffix(startLetters: condition.startLetters, starter: starter.move, opponent: starter.move)
    }
    var games = [[Record]]()
    for _ in 1...condition.trials {
      games.append(process(game))
    }
    return games
  }
  func createSubject(from subject: Condition.Subject) -> Player {
    let radix = Radix()
    let dict = subject.wordList.words()
    dict?.forEach {radix.insert($0)}
    return .init(radix)
  }
  func process(_ game: Begriffix) -> [Record] {
    var moves = [Record]()
    for (game, move) in game {
      moves.append(process(move, game: game))
    }
    return moves
  }
  func process(_ move: Begriffix.Move, game: Begriffix) -> Record {
    let pattern = game.pattern(of: move.place)
    let places = move.places?.count ?? 0
    let words = move.places?.map({$0.1.count}).sum() ?? 0
    return .init(move: move, pattern: pattern, places: places, words: words)
  }
}
