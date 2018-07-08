import Foundation
import HangMan

class Player {
  static let dict: Set<String> = loadDict("german") ?? Set()
  static func loadDict(_ lang: String) -> Set<String>? {
    let b = Bundle(for: Radix.self)
    guard let url = b.url(forResource: "dictionaries/\(lang)", withExtension: "txt") else {return nil}
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {return nil}
    var data = Set(content.lowercased().components(separatedBy: "\n"))
    data.remove("")
    return data
  }
  let vocabulary = Radix()
  init() {
    let words = Player.dict
    vocabulary.insert(words)
  }
  func deal(with state: State) -> Move? {
    let dir: Move.Direction = state.player ? .Horizontal : .Vertical
    let lower = state.options.contains(.includeThree) ? 3 : 4
    for count in stride(from: 8, through: lower, by: -1) {
      var move = Move(direction: dir, count: count)
      let p = state.scan(for: move)
   if p.count == 0 {continue}
      move.start = p[0]
      let pattern = move.pattern(state.board)
      let matches = vocabulary.match(pattern)
      if matches.count == 0 {continue}
      move.word = matches[0]
      return move
    }
    return nil
  }
  }
