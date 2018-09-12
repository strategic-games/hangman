import Foundation
import Utility
import Games

struct BegriffixSimulation {
  typealias Game = Begriffix
  struct Info: Codable {
    static let dateFormatter = DateFormatter.ISOFormatter()
    /// A one-line description of the experiment
    let title: String
    /// More comments, descriptions, explanations
    let supplement: String?
    /// The build number of this software
    let version: String?
    /// When the measurement was started
    let date = dateFormatter.string(from: Date())
    /// The simulated game name
    let game = Game.name
  }
  struct Condition: Codable {
    struct Subject: Hashable, Codable {
      enum Vocabulary: Hashable {
        case full(WordList)
        case prefix(Int, WordList)
        case suffix(Int, WordList)
        case sample(Int, WordList)
        case custom([String])
        func load() -> Radix {
          let radix = Radix()
          switch self {
          case .full(let wordList):
            wordList.words()?.forEach {radix.insert($0)}
          case let .prefix(count, wordList):
            wordList.words()?.prefix(count).forEach {radix.insert($0)}
          case let .suffix(count, wordList):
            wordList.words()?.suffix(count).forEach {radix.insert($0)}
          case let .sample(count, wordList):
            wordList.words()?.sample(count)?.forEach {radix.insert($0)}
          case .custom(let words):
            words.forEach {radix.insert($0)}
          }
          return radix
        }
      }
      let vocabulary: Vocabulary
      var player: Player {
        return .init(vocabulary.load())
      }
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
  var info: Info
  var conditions: [Condition]
  var result: [[[Record]]]?
  mutating func process() {
    result = conditions.map {process($0)}
  }
  func process(_ condition: Condition) -> [[Record]] {
    let starter = condition.starter.player
    let game: Begriffix
    if let opponentSubject = condition.opponent {
      let opponent = opponentSubject.player
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

extension BegriffixSimulation: Codable {
  enum CodingKeys: CodingKey {
    case info, conditions, result
  }
}

extension BegriffixSimulation.Condition.Subject.Vocabulary: Codable {
  enum CodingKeys: CodingKey {
    case full, prefix, suffix, sample, custom
  }
  struct PartialWordList: Codable {
    let wordList: WordList
    let count: Int
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .full(wordList):
      try container.encode(wordList, forKey: .full)
    case let .prefix(count, wordList):
      try container.encode(PartialWordList(wordList: wordList, count: count), forKey: .prefix)
    case let .suffix(count, wordList):
      try container.encode(PartialWordList(wordList: wordList, count: count), forKey: .suffix)
    case let .sample(count, wordList):
      try container.encode(PartialWordList(wordList: wordList, count: count), forKey: .sample)
    case let .custom(values):
      try container.encode(values, forKey: .custom)
    }
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let full = try? container.decode(WordList.self, forKey: .full) {
      self = .full(full)
    } else if let prefix = try? container.decode(PartialWordList.self, forKey: .prefix) {
        self = .prefix(prefix.count, prefix.wordList)
    } else if let suffix = try? container.decode(PartialWordList.self, forKey: .suffix) {
      self = .suffix(suffix.count, suffix.wordList)
    } else if let sample = try? container.decode(PartialWordList.self, forKey: .sample) {
      self = .sample(sample.count, sample.wordList)
    } else {
      let custom = try container.decode([String].self, forKey: .custom)
      self = .custom(custom)
    }
  }
}
