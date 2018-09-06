import Foundation
import SwiftCLI
import Utility
import Games

class PlayCommand: Command {
  let name = "play"
  func execute() throws {
    let startLetters: [[Unicode.Scalar]] = [["l", "a"], ["e", "r"]]
      let game = Begriffix(startLetters: startLetters, starter: DefaultPlayer(), opponent: HumanPlayer(id: "Terminator"))!
      for (state, _) in game {
        stdout <<< state.board.description
      }
  }
}
