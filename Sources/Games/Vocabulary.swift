import Utility

/// Specify a player's vocabulary
public enum Vocabulary: Hashable {
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
  public func load() -> Radix {
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

extension Vocabulary: Codable {
  enum CodingKeys: CodingKey {
    case full, prefix, suffix, sample, randomSize, custom
  }
  struct PartialWordList: Codable {
    let wordList: WordList
    let count: Int
  }
  public func encode(to encoder: Encoder) throws {
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
  public init(from decoder: Decoder) throws {
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
