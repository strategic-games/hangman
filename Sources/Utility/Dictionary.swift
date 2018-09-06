import Foundation

/// Word lists that can be used for verbal games
public enum WordList: String {
  case ScrabbleDict = "german"
  case English = "english"
  case Derewo = "derewo-v-100000t-2009-04-30-0.1"
  public var url: URL? {
    return Bundle(path: "hangman")?
      .url(forResource: self.rawValue, withExtension: "txt", subdirectory: "dictionaries")
  }
}
