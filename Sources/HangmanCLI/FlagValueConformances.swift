import Guaka
import Utility

extension WordList: FlagValue {
  public static func fromString(flagValue value: String) throws -> WordList {
    guard let wordList = WordList(rawValue: value) else {
      throw FlagValueError.conversionError("not a valid word list name")
    }
    return wordList
  }
  public static var typeDescription: String {
    return "A bundled word list ID"
  }
}
