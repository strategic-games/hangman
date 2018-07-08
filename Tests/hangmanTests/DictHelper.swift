import Foundation
import HangMan

class DictHelper {
  static func loadData(_ lang: String) -> Set<String>? {
    let b = Bundle(for: Radix.self)
    guard let url = b.url(forResource: "dictionaries/\(lang)", withExtension: "txt") else {return nil}
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {return nil}
    var data = Set(content.lowercased().components(separatedBy: "\n"))
    data.remove("")
    return data
  }
}
