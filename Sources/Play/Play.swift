import Foundation
import SwiftCLI
import Utility
import Games

class PlayCommand: Command {
  let name = "play"
  func execute() throws {
    let startLetters: [[Unicode.Scalar]] = [["l", "a"], ["e", "r"]]
    let starter = Player()
      var game = Begriffix(startLetters: startLetters, starter: starter.move, opponent: self.move)
    try game?.play()
  }
  func move(_ game: Begriffix) -> Begriffix.Move? {
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
      let start: Point = Input.readObject(
        prompt: "start"
      )
      print(start)
      let place = Place(start: start, direction: dir, count: word.count)
      if game.contains(place) {
        WriteStream.stdout <<< "move will be applied"
        return Begriffix.Move(place, Array(word.unicodeScalars))
      }
      WriteStream.stderr <<< "no valid move, please try again"
    }
  }
}
