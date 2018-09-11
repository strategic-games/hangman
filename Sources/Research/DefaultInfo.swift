import Foundation
import Games

struct DefaultInfo<Game: Games.Game>: Codable {
  /// A one-line description of the experiment
  let title: String
  /// More comments, descriptions, explanations
  let supplement: String?
  /// The build number of this software
  let version: String?
  /// When the measurement was started
  let date = Date()
  /// The simulated game name
  let game = Game.name
}
