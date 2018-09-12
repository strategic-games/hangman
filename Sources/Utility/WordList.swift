import Foundation

/// Word lists that can be used for verbal games
public enum WordList: String, CaseIterable, Codable {
  /// A very long german word list from ScrabbleDict
  case ScrabbleDict
  /// The „Wortformenliste“ by Derewo, a german corpus-based project
  case Derewo
  /// An english word list, unknown origin
  case English
  /// The name of the resource text file
  var resource: String {
    switch self {
    case .ScrabbleDict: return "german"
    case .Derewo: return "derewo-v-100000t-2009-04-30-0.1"
    case .English: return "english"
    }
  }
  /// The resource URL in the bundle
  var url: URL? {
    return Bundle(for: Radix.self)
      .url(forResource: self.resource, withExtension: "txt", subdirectory: "dictionaries")
  }
  /// Returns the file content as string if it loads successfully
  public func load() -> String? {
    guard let url = self.url else {return nil}
    return try? String(contentsOf: url)
  }
  /// Returns the loaded word list if loading successfully
  public func words() -> [[Unicode.Scalar]]? {
    guard let str = load() else {return nil}
    return str.lowercased().unicodeScalars
      .split(separator: "\n")
      .drop(while: {$0.first == "#"})
      .map {Array($0.prefix(while: {$0 != " "}))}
  }
}

public extension RangeReplaceableCollection {
  /// Take a random sample from a range replaceable collection
  func sample(_ size: Int) -> [Element]? {
    guard !isEmpty else {return nil}
    var population = self
    var sample = [Element]()
    sample.reserveCapacity(size)
    repeat {
      guard let i = indices.randomElement() else {return nil}
      sample.append(population.remove(at: i))
    } while sample.count < size
    return sample
  }
}
