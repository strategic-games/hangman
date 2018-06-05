import Foundation

/**
A small helper struct for loading the dictionary files included in the package
*/
public struct ScrabbleDict {
  /**
  The possible languages, which dictionaries exist for
  */
  public enum Language: String {
    case english, german
  }
  /**
  The dictionary language
  */
  public let language: Language
  /**
 The dictionary word list as a Set
  */
  public let data: Set<String>
  /**
  Create a ScrabbleDict with a given Language
  */
  public init?(lang: Language) {
    language = lang
    guard let url = Bundle(for: Hangman.self).url(forResource: lang.rawValue, withExtension: "txt") else {
      return nil
    }
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {
      return nil
    }
    var tmp = Set(content.lowercased().components(separatedBy: "\n"))
    tmp.remove("")
    data = tmp
  }
}
