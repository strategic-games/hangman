import Foundation
import Utility

/// Specify a player's vocabulary
public struct Vocabulary: Hashable, Codable {
  public struct WordList: Hashable {
    typealias Words = [[Unicode.Scalar]]
    private static var fileCache = [String: Words]()
    public let path: String
    private var url: URL {
      return URL(fileURLWithPath: path)
    }
    func parse() throws -> [[Unicode.Scalar]] {
      if let parsed = WordList.fileCache[path] {
        return parsed
      }
      let contents = try load()
      let words = contents.lowercased().unicodeScalars
        .split(separator: "\n")
        .drop(while: {$0.first == "#"})
        .map {Array($0.prefix(while: {$0 != " "}))}
      WordList.fileCache[path] = words
      return words
    }
    func load() throws -> String {
      return try String(contentsOf: url)
    }
  }
  /// The parts of a word list to take
  public enum Selector: Hashable {
    /// Take the word list from its initial word up to a maximum number
    case prefix(Int)
    /// Take a word list from its end up to a maximum number
    case suffix(Int)
    /// Take a random sample with given size from a word list
    case sample(Int)
  }
  private static var radixCache = [Vocabulary: Radix]()
  /// The word list the vocabulary is based on
  public let base: WordList
  /// The part to take from the base word list
  public let select: Selector?
  /// Initialize a new vocabulary
  public init(base: WordList, select: Selector? = nil) {
    self.base = base
    self.select = select
  }
  func load() throws -> Radix {
    if let radix = Vocabulary.radixCache[self] {
      return radix
    }
    let dict = try base.parse()
    let radix = Radix()
    guard let select = self.select else {
      radix.insert(dict)
      return radix
    }
    switch select {
    case .prefix(let count):
      radix.insert(dict.prefix(count))
    case .suffix(let count):
      radix.insert(dict.suffix(count))
    case .sample(let count):
      radix.insert(dict.sample(count) ?? [])
    }
    return radix
  }
}

extension Vocabulary.WordList: Codable {
  public init(from decoder: Decoder) throws {
    path = try String(from: decoder)
  }
  public func encode(to encoder: Encoder) throws {
    try path.encode(to: encoder)
  }
}

extension Vocabulary.Selector: Codable {
  private enum CodingKeys: CodingKey {
    case prefix, suffix, sample
  }
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.prefix) {
      let count = try container.decode(Int.self, forKey: .prefix)
      self = .prefix(count)
    } else if container.contains(.suffix) {
      let count = try container.decode(Int.self, forKey: .suffix)
      self = .suffix(count)
    } else if container.contains(.sample) {
      let count = try container.decode(Int.self, forKey: .sample)
      self = .sample(count)
    } else {
      throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "No valid selector case was found"))
    }
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .prefix(let count):
      try container.encode(count, forKey: .prefix)
    case .suffix(let count):
      try container.encode(count, forKey: .suffix)
    case .sample(let count):
      try container.encode(count, forKey: .sample)
    }
  }
}

