import Foundation

public struct ScrabbleDict {
  public enum Language: String {
    case english, german
  }
  public let language: Language
  public let data: Set<String>
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
