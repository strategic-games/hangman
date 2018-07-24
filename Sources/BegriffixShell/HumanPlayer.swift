import SwiftCLI
import Begriffix

struct HumanPlayer: Player {
  func deal(with state: State) -> Move? {
    while true {
      let word = Input.readLine(prompt: "word")
      if word.isEmpty {return nil}
      let dir: Direction
      switch state.phase {
      case let .Restricted(currentDir):
        dir = currentDir
      case .Liberal:
        let currentDir = Input.readBool(
          prompt: "direction (horizontal = true, vertical = false):"
        )
        dir = currentDir ? .Horizontal : .Vertical
      case .KnockOut: return nil
      }
      let start: Position = Input.readObject(
        prompt: "start"
      )
      let place = Place(start: start, direction: dir, count: word.count)
      if state.contains(place: place) {
        WriteStream.stdout <<< "move will be applied"
        return Move(place: place, word: word)
      }
      WriteStream.stderr <<< "no valid move, please try again"
    }
  }
}
