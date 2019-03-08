import Foundation
import Guaka
import Utility

extension SGWordLists {
  var dictionary: [String: [String]] {
    return [String: [String]](uniqueKeysWithValues: self.entries.map {($0.key, $0.value)})
  }
}

extension SGVocabulary {
  static var radixCache = [SGVocabulary: Radix]()
  func selected(from lists: [String: [String]]) -> Radix {
    if let radix = SGVocabulary.radixCache[self] {
      return radix
    }
    let list = lists[key] ?? []
    let radix = selected(from: list)
    SGVocabulary.radixCache[self] = radix
    return radix
  }
  func selected(from list: [String]) -> Radix {
    let radix = Radix()
    guard let select = self.select else {
      radix.insert(list)
      return radix
    }
    switch select {
    case .prefix(let count):
      radix.insert(list.prefix(Int(count)))
    case .suffix(let count):
      radix.insert(list.suffix(Int(count)))
    case .sample(let count):
      radix.insert(list.sample(Int(count)) ?? [])
    }
    return radix
  }
}
