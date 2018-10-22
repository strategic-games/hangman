import Foundation
import Guaka
import Utility
import Games

extension Simulation {
  enum DataFormat: String, FlagValue {
    case proto
    case json
    static func fromString(flagValue value: String) throws -> DataFormat {
      guard let mode = DataFormat(rawValue: value) else {
        throw FlagValueError.conversionError("mode must be proto or json")
      }
      return mode
    }
    static let typeDescription = "The data format of a simulation config file"
  }
  func run(streamer: SimulationStreamer) throws {
    var results = SimulationResults()
    for (n, c) in conditions.enumerated() {
      print("running condition \(n)")
      guard let game = Begriffix(condition: c) else {
        print("couldn't create game")
        continue
      }
      let n = UInt32(n)
      for t in 0..<c.trials {
        print("running trial \(t)")
        let moves = game.map {
          return SimulationResults.Move($0.1)
        }
        let trial = SimulationResults.Trial.with {
          $0.condition = n
          $0.trial = t
          $0.moves = moves
        }
        results.trials = [trial]
        let data = try results.serializedData()
        streamer.append(data)
      }
    }
  }
}

extension Simulation.Info {
  /// A filename string composed of title and date
  public var fileName: String {
    let message = title.split(separator: " ").joined(separator: "_")
    return "simulation_\(date.date)_\(message).pb"
  }
  var url: URL {
    return URL(fileURLWithPath: fileName)
  }
}

extension Begriffix {
  init?(condition: Simulation.Condition) {
    guard let starter = try? Player(config: condition.starter) else {return nil}
    let opponent = (try? Player(config: condition.opponent)) ?? starter
    self.init(startLetters: condition.startLetters, starter: starter.move, opponent: opponent.move)
  }
}

extension Player {
  init(config: Simulation.Condition.Player) throws {
    let radix = try config.vocabulary.load()
    self.init(radix)
  }
}

extension SimulationResults.Trial {
  init(condition: Int, trial: Int, moves: [Begriffix.Move]) {
    self.condition = UInt32(condition)
    self.trial = UInt32(trial)
    self.moves = moves.map {SimulationResults.Move($0)}
  }
}

extension SimulationResults.Move {
  init(_ move: Begriffix.Move) {
    self.place = SimulationResults.Place(move.place)
    self.word = String(String.UnicodeScalarView(move.word))
    if let hits = move.hits {
      self.hits = hits.map {SimulationResults.Hit($0.key, $0.value)}
    }
  }
}

extension SimulationResults.Hit {
  init(_ place: Place, _ words: [Begriffix.Word]) {
    self.place = SimulationResults.Place(place)
    self.words = words.map {String(String.UnicodeScalarView($0))}
  }
}

extension SimulationResults.Place {
  init(_ place: Games.Place) {
    self.column = UInt32(place.start.column)
    self.row = UInt32(place.start.row)
    switch place.direction {
    case .Horizontal: self.direction = .horizontal
    case .Vertical: self.direction = .vertical
    }
  }
}
