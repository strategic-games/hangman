import Utility
import Games

public protocol FileNameConvertible {
  var fileName: String {get}
}

/// A game simulation where AI players can play against each other
public struct BegriffixSimulation: Codable {
  struct Player: Codable {
    let vocabulary: Vocabulary
  }
  struct Result: Codable {
    let move: Begriffix.Move
    let hits: [Begriffix.Hit]
  }
  struct Condition: Codable {
    let startLetters: String
    let starter: Player
    let opponent: Player?
    let trials: Int
    var results: [[Result]]?
    public mutating func run() throws {
      let starterRadix: Radix = try self.starter.vocabulary.load()
      let opponentRadix = try self.opponent?.vocabulary.load() ?? starterRadix
      let starter = Games.Player(starterRadix)
      let opponent = Games.Player(opponentRadix)
      let game = Begriffix(startLetters: startLetters, starter: starter.move, opponent: opponent.move)
      var games = [[Result]]()
      games.reserveCapacity(trials)
      for _ in 1...trials {
        var results = [Result]()
        for (_, move, hits) in game {
          results.append(.init(move: move, hits: hits))
        }
        games.append(results)
      }
      self.results = games
    }
  }
  /// Describing metadata of a simulation
  public var info: Info
  /// A list of game descriptions that should be played in a simulation
  var conditions: [Condition]
  /// Play the games in conditions and assign the results to the result property accordingly
  public mutating func process() throws {
    conditions = try conditions.map {
      var condition = $0
      try condition.run()
      return condition
    }
  }
}

extension BegriffixSimulation: FileNameConvertible {
  public var fileName: String {return info.filename}
}
