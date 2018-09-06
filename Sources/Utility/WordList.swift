import Foundation

/// Word lists that can be used for verbal games
public enum WordList: String, CaseIterable {
  case ScrabbleDict = "german"
  case English = "english"
  case Derewo = "derewo-v-100000t-2009-04-30-0.1"
  var url: URL? {
    return Bundle(for: Radix.self)
      .url(forResource: self.rawValue, withExtension: "txt", subdirectory: "dictionaries")
  }
  public func load() -> String? {
    guard let url = self.url else {return nil}
    return try? String(contentsOf: url)
  }
}
