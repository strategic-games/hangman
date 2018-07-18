import Foundation
import HangMan

/// A Begriffix player
class Player {
  static let dict: Set<String> = loadDict("german") ?? Set()
  static let radix: Radix = createRadix()
  static func loadDict(_ lang: String) -> Set<String>? {
    let b = Bundle(for: Radix.self)
    guard let url = b.url(forResource: "dictionaries/\(lang)", withExtension: "txt") else {return nil}
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {return nil}
    var data = Set(content.lowercased().components(separatedBy: "\n"))
    data.remove("")
    return data
  }
  static func createRadix() -> Radix {
    let radix = Radix()
    radix.insert(Player.dict)
    return radix
  }
  /// Return a move for a given game state
  func deal(with state: State) -> Move? {
    switch state.phase {
    case .Restricted: return dealRestricted(with: state)
    case .Liberal: return dealLiberal(with: state)
    case .KnockOut: return nil
    }
  }
  private func dealRestricted(with state: State) -> Move? {
    var places = [Place:[String]]()
    let dir: Direction = state.player ? .Horizontal : .Vertical
    for count in stride(from: 8, through: 4, by: -1) {
      let p = state.scan(direction: dir, count: count)
      if p.isEmpty {continue}
      for s in p {
        let place = Place(start: s, direction: dir, count: count)
        let matches = match(state, place: place)
        if matches.isEmpty {continue}
        places[place] = matches
      }
    }
    return select(from: places)
  }
  private func dealLiberal(with state: State) -> Move? {
    var places = [Place:[String]]()
    for dir in Direction.allCases {
      for count in stride(from: 8, through: 3, by: -1) {
        let p = state.scan(direction: dir, count: count)
        if p.isEmpty {continue}
        for s in p {
          let place = Place(start: s, direction: dir, count: count)
          let matches = match(state, place: place)
          if matches.isEmpty {continue}
          places[place] = matches
        }
      }
    }
    return select(from: places)
  }
  /// Find the words that could be inserted at the given place
  func match(_ state: State, place: Place) -> [String] {
    let pattern = state.board[place].map {$0 ?? "?"}
    return Player.radix.match(String(pattern)).filter { word in
      let words = state.words(orthogonalTo: place, word: word)
      return words.allSatisfy {Player.radix.contains($0)}
    }
  }
  /// Select a move from valid places and their words
  func select(from places: [Place:[String]]) -> Move? {
    guard let (place, words) = places.randomElement() else {return nil}
    guard let word = words.randomElement() else {return nil}
    let wordSum = places.map({(_, words) in words.count}).sum()
    return Move(place: place, word: word, sum: wordSum)
  }
  }
