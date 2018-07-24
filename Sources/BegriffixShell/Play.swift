import Foundation
import SwiftCLI
import HangMan
import Begriffix

class PlayCommand: Command {
  let name = "play"
  let input = Key<String>("-i", "--input", description: "Path to a json file containing a radix serialization")
  func execute() throws {
    let file = URL(fileURLWithPath: input.value ?? "dictionaries/german.txt")
    let text = try String(contentsOf: file)
    let radix = Radix()
    radix.insert(text: text)
    let game = Game(starter: RandomPlayer(vocabulary: radix), opponent: HumanPlayer())
    //stdout <<< game.state.description
    for (state, move) in game {
      stdout <<< state.board.description
    }
  }
}
