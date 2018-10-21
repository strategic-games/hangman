import Foundation
import Utility

extension WordList {
  init(source: String, text: String) {
    self.source = source
    words = text.lowercased().unicodeScalars
      .split(separator: "\n")
      .drop(while: {$0.first == "#"})
      .map {String($0.prefix(while: {$0 != " "}))}
  }
}

extension Vocabulary {
  static var fileCache = [URL: WordList]()
  static var radixCache = [Vocabulary: Radix]()
  var url: URL {
    return URL(fileURLWithPath: path)
  }
  /// Returns the vocabulary as radix tree
  func load() throws -> Radix {
    if let radix = Vocabulary.radixCache[self] {
      return radix
    }
    let radix = try createSelected()
    Vocabulary.radixCache[self] = radix
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
  func loadList() throws -> WordList {
    if let list = Vocabulary.fileCache[url] {return list}
    let data = try Data(contentsOf: url)
    let list = try WordList(serializedData: data)
    Vocabulary.fileCache[url] = list
    return list
  }
}
