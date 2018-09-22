import Games

/// A game simulation where AI players can play against each other
public struct Simulation: Codable {
  /// Describing metadata of a simulation
  public var info: Info
  /// A list of game descriptions that should be played in a simulation
  var conditions: [Condition]
  /// Play the games in conditions and assign the results to the result property accordingly
  public mutating func process() {
    conditions = conditions.map {$0.run()}
  }
}

