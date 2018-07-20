import SwiftCLI
import Begriffix

class PlayCommand: Command {
  let name = "play"
  func execute() {
    stdout <<< "playing is fun"
  }
}
