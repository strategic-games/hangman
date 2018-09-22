import Games

/// A type that stores game parameters
public enum Condition {
  case begriffix(Begriffix.Configuration, Int, [[Begriffix.Move]]?)
  public func run() -> Condition {
    switch self {
    case let .begriffix(config, trials, _):
      let game = Begriffix(from: config)
      var result = [[Begriffix.Move]]()
      result.reserveCapacity(trials)
      for _ in 1...trials {
        var moves = [Begriffix.Move]()
        for (_, move) in game {
          moves.append(move)
        }
        result.append(moves)
      }
      return .begriffix(config, trials, result)
    }
  }
}

extension Condition: Codable {
  public enum CodingKeys: CodingKey {
    case game, config, trials, result
  }
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let game = try container.decode(String.self, forKey: .game)
    let trials = try container.decode(Int.self, forKey: .trials)
    switch game {
    case "begriffix":
      let config = try container.decode(Games.Begriffix.Configuration.self, forKey: .config)
      let result = try container.decode([[Games.Begriffix.Move]].self, forKey: .result)
      self = .begriffix(config, trials, result)
    default:
      throw DecodingError.keyNotFound(CodingKeys.game, .init(codingPath: decoder.codingPath, debugDescription: "no valid game name"))
    }
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .begriffix(config, trials, result):
      try container.encode("begriffix", forKey: .game)
      try container.encode(config, forKey: .config)
      try container.encode(trials, forKey: .trials)
      try container.encode(result, forKey: .result)
    }
  }
}
