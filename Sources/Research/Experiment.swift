import Utility

struct ExperimentDescription: Codable {
  struct Vocabulary: Codable {
    enum Mode: Codable {
      case Full, Prefix(Int), Suffix(Int), Random(Int)
      enum CodingKeys: CodingKey {
        case prefix, suffix, random
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .Prefix(let value):
          try container.encode(value, forKey: .prefix)
        case .Suffix(let value):
          try container.encode(value, forKey: .suffix)
        case .Random(let value):
          try container.encode(value, forKey: .random)
        case .Full:
          var container = encoder.singleValueContainer()
          try container.encode("full")
        }
      }
      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(Int.self, forKey: .prefix) {
          self = .Prefix(value)
        } else if let value = try? container.decode(Int.self, forKey: .suffix) {
          self = .Suffix(value)
        } else if let value = try? container.decode(Int.self, forKey: .random) {
          self = .Random(value)
        } else {
          self = .Full
        }
      }
    }
    let wordList: WordList
    let mode: Mode
  }
  struct Game: Codable {
    let startLetters: Int
    let starter: Int
    let opponent: Int
    let count: Int
  }
  let vocabularies: [Vocabulary]
  let startLetters: [String]
  let games: [Game]
  func isValid() -> Bool {
    guard startLetters.allSatisfy({$0.count == 4}) else {return false}
    return games.allSatisfy { (game: Game) -> Bool in
      if !startLetters.indices.contains(game.startLetters) {return false}
      if !vocabularies.indices.contains(game.starter) {return false}
      if !vocabularies.indices.contains(game.opponent) {return false}
      return true
    }
  }
}
