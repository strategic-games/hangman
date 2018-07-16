import Foundation
import HangMan

class Player {
  struct Place {
    let start: Position
    let direction: Direction
    let words: [String]
  }
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
  func deal(with state: State) -> Move? {
    switch state.phase {
    case .Restricted: return dealRestricted(with: state)
    case .Liberal: return dealLiberal(with: state)
    case .KnockOut: return nil
    }
  }
  func dealRestricted(with state: State) -> Move? {
    var places = [Place]()
    let dir: Direction = state.player ? .Horizontal : .Vertical
    for count in stride(from: 8, through: 4, by: -1) {
      let p = state.scan(direction: dir, count: count)
      if p.isEmpty {continue}
      for s in p {
        let pattern = state.board[s, dir, count].map {$0 ?? "?"}
        let matches = Player.radix.match(String(pattern))
        if matches.isEmpty {continue}
        places.append(Place(start: s, direction: dir, words: matches))
      }
    }
    return select(from: places)
  }
  func dealLiberal(with state: State) -> Move? {
    var places = [Place]()
    for dir in Direction.allCases {
      for count in stride(from: 8, through: 3, by: -1) {
        let p = state.scan(direction: dir, count: count)
        if p.isEmpty {continue}
        for s in p {
          let matches = match(state: state, start: s, dir: dir, count: count)
          if matches.isEmpty {continue}
          places.append(Place(start: s, direction: dir, words: matches))
        }
      }
    }
    return select(from: places)
  }
  func match(state: State, start: Position, dir: Direction, count: Int) -> [String] {
    let pattern = state.board[start, dir, count].map {$0 ?? "?"}
    let matches = Player.radix.match(String(pattern)).filter {validate(state, with: Move(start: start, direction: dir, word: $0, sum: 0))}
    return matches
  }
  func validate(_ state: State, with move: Move) -> Bool {
    let newState = state + move
    let words = newState.words(move.direction.toggled(), lines: move.lines())
    return words.joined().allSatisfy {Player.radix.contains($0)}
  }
  func select(from places: [Place]) -> Move? {
    guard let place = places.randomElement() else {return nil}
    guard let word = place.words.randomElement() else {return nil}
    let wordSum = places.map({$0.words.count}).sum()
    return Move(start: place.start, direction: place.direction, word: word, sum: wordSum)
  }
  }
