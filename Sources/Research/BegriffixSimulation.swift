import Foundation
import Utility
import Games

/// A game simulation where AI players can play against each other
struct BegriffixSimulation {
  /// The game which is played
  typealias Game = Begriffix
  /// Describing metadata
  struct Info: Codable {
    /// A date formatter that outputs date strings in ISO 8601 format
    static let dateFormatter = DateFormatter.ISOFormatter()
    /// The simulated game name
    let game = Game.name
    /// A one-line description of the experiment
    let title: String
    /// More comments, descriptions, explanations
    let supplement: String?
    /// When the measurement was started
    var date: String?
    /// The build number of this software
    var version: String?
    /// A filename string composed of game, title and date
    var filename: String {
      let message = title.split(separator: " ").joined(separator: "_")
      return "simulation_\(game)_\(message)_\(date!)"
    }
    mutating func prepare() {
      version = Version.description
      date = Info.dateFormatter.string(from: Date())
    }
  }
  /// A type that stores game parameters
  struct Condition: Codable {
    /// A type that stores player parameters
    struct Subject: Hashable, Codable {
      /// An enum that contains vocabulary selection data
      enum Vocabulary: Hashable {
        /// Take a complete word list
        case full(WordList)
        /// Take the word list from its initial word up to a maximum number
        case prefix(Int, WordList)
        /// Take a word list from its end up to a maximum number
        case suffix(Int, WordList)
        /// Take a random sample with given size from a word list
        case sample(Int, WordList)
        /// Take a sample with randomly selected size
        case randomSize(WordList)
        /// Take a customized list of strings
        case custom([String])
        /// Returns a searchable radix tree with the words inserted
        func load() -> Radix {
          let radix = Radix()
          switch self {
          case .full(let wordList):
            wordList.words().forEach {radix.insert($0)}
          case let .prefix(count, wordList):
            wordList.words().prefix(count).forEach {radix.insert($0)}
          case let .suffix(count, wordList):
            wordList.words().suffix(count).forEach {radix.insert($0)}
          case let .sample(count, wordList):
            wordList.words().sample(count)?.forEach {radix.insert($0)}
          case let .randomSize(wordList):
            let list = wordList.words()
            let count = (1...list.count).randomElement()!
            list.sample(count)?.forEach {radix.insert($0)}
          case .custom(let words):
            words.forEach {radix.insert($0)}
          }
          return radix
        }
      }
      /// A player's vocabulary
      let vocabulary: Vocabulary
      /// A player object conforming to this description
      var player: Player {
        return .init(vocabulary.load())
      }
    }
    /// A four-letter combination the game starts with
    let startLetters: Begriffix.Word
    /// A player description of the starter
    let starter: Subject
    /// A player description of the opponent
    let opponent: Subject?
    /// Indicates how many times the game is played
    let trials: Int
  }
  /// A game move with some extra data
  struct Record: Codable {
    /// The move returned from a player
    let move: Begriffix.Move
    /// The letter pattern the move was based on
    let pattern: Begriffix.Pattern
    /// Indicates how many places on the board the player had to choose from
    let places: Int
    /// Indicates how many words the player had to choose from
    let words: Int
  }
  /// Describing metadata of a simulation
  var info: Info
  /// A list of game descriptions that should be played in a simulation
  var conditions: [Condition]
  /// A list of game results corresponding to conditions where one result is a list of trials which is a list of records
  var result: [[[Record]]]?
  /// Play the games in conditions and assign the results to the result property accordingly
  mutating func process() {
    info.prepare()
    result = conditions.map {process($0)}
  }
  /// Play the game in one condition and repeat for the given number of trials
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
  /// Play a single game
  func process(_ game: Begriffix) -> [Record] {
    var moves = [Record]()
    for (game, move) in game {
      moves.append(process(move, game: game))
    }
    return moves
  }
  /// Create a record from a move and the corresponding game
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
    case full, prefix, suffix, sample, randomSize, custom
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
    case .randomSize(let wordList):
      try container.encode(wordList, forKey: .sample)
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
    } else if let randomSize = try? container.decode(WordList.self, forKey: .randomSize) {
      self = .randomSize(randomSize)
    } else {
      let custom = try container.decode([String].self, forKey: .custom)
      self = .custom(custom)
    }
  }
}
