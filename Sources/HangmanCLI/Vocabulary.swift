import Foundation
import Guaka
import Utility

extension SGWordList {
  enum DataFormat: String, FlagValue {
    case proto
    case text
    static func fromString(flagValue value: String) throws -> DataFormat {
      guard let mode = DataFormat(rawValue: value) else {
        throw FlagValueError.conversionError("mode must be proto or text")
      }
      return mode
    }
    static let typeDescription = "The data format of a word list file"
  }

  init(source: String, text: String) {
    self.source = source
    words = text.lowercased().unicodeScalars
      .split(separator: "\n")
      .drop(while: {$0.first == "#"})
      .map {String($0.prefix(while: {$0 != " "}))}
  }
}

extension SGVocabulary {
  static var fileCache = [URL: SGWordList]()
  static var radixCache = [SGVocabulary: Radix]()
  var url: URL {
    return URL(fileURLWithPath: path)
  }
  /// Returns the vocabulary as radix tree
  func load() throws -> Radix {
    if let radix = SGVocabulary.radixCache[self] {
      return radix
    }
    let radix = try createSelected()
    SGVocabulary.radixCache[self] = radix
    return radix
  }
  func createSelected() throws -> Radix {
    let list = try loadList()
    let radix = Radix()
    guard let select = self.select else {
      radix.insert(list.words)
      return radix
    }
    switch select {
    case .prefix(let count):
      radix.insert(list.words.prefix(Int(count)))
    case .suffix(let count):
      radix.insert(list.words.suffix(Int(count)))
    case .sample(let count):
      radix.insert(list.words.sample(Int(count)) ?? [])
    }
    return radix
  }
  func loadList() throws -> SGWordList {
    if let list = SGVocabulary.fileCache[url] {return list}
    let data = try Data(contentsOf: url)
    let list = try SGWordList(serializedData: data)
    SGVocabulary.fileCache[url] = list
    return list
  }
}