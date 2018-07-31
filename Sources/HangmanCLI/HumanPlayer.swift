import SwiftCLI
import Hangman

struct HumanPlayer: Player {
  func deal(with game: Begriffix) -> Begriffix.Move? {
    while true {
      let word = Input.readLine(prompt: "word")
      if word.isEmpty {return nil}
      let dir: Direction
      switch game.phase {
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
      if game.contains(place: place) {
        WriteStream.stdout <<< "move will be applied"
        return Begriffix.Move(place: place, word: Array(word.unicodeScalars))
      }
      WriteStream.stderr <<< "no valid move, please try again"
    }
  }
}

extension Position: ConvertibleFromString {}
