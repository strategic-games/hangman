import Foundation
import SwiftCLI
import Games

struct DefaultInfo<Game: BoardGame>: Codable {
  /// A one-line description of the experiment
  let title: String?
  /// More comments, descriptions, explanations
  let supplement: String?
  /// The build number of this software
  let version: String?
  /// When the measurement was started
  let date = Date()
  /// The simulated game name
  let game = Game.name
}

extension DefaultInfo: Fixable {
  func fixed() -> DefaultMetadata {
    let title = self.title ?? Input.readObject(prompt: "Title")
    let version = self.version ?? Input.readObject(prompt: "Version")
    return DefaultMetadata(title: title, version: version)
  }
  mutating func fix() {
    self = fixed()
  }
}
