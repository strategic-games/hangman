import Foundation

/// Word lists that can be used for verbal games
public enum WordList: String, CaseIterable {
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
}
