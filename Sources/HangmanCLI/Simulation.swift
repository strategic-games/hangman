import Foundation
import Guaka
import Utility
import Games

extension SGSimulation {
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
    let firstEntry = SGSimulationResults.with {
      $0.config = self
    }
    try streamer.append(firstEntry.serializedData())
    for (conditionIndex, condition) in conditions.enumerated() {
      print("running condition \(conditionIndex)")
      guard let game = Begriffix(condition: condition) else {
        print("couldn't create game")
        continue
      }
      let conditionIndex = UInt32(conditionIndex)
      for trialIndex in 0..<condition.trials {
        print("running trial \(trialIndex)")
        let results = SGSimulationResults.with {
          let trial = SGSimulationResults.Trial.with {
            $0.condition = conditionIndex
            $0.trial = trialIndex
            $0.moves = game.map {
              return SGSimulationResults.Move($0.1)
            }
          }
          $0.trials = [trial]
        }
        let data = try results.serializedData()
        streamer.append(data)
      }
    }
  }
}

extension SGSimulation.Info {
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
  init?(condition: SGSimulation.Condition) {
    guard let starter = try? Player(config: condition.starter) else {return nil}
    let opponent = (try? Player(config: condition.opponent)) ?? starter
    let vocabulary = try? condition.vocabulary.load()
    self.init(startLetters: condition.startLetters, starter: starter.move, opponent: opponent.move, vocabulary: vocabulary)
  }
}

extension Player {
  init(config: SGSimulation.Condition.Player) throws {
    let radix = try config.vocabulary.load()
    let begriffixStrategy: BegriffixStrategy
    switch config.begriffixStrategy {
    case .random: begriffixStrategy = randomBegriffixStrategy
    case .short: begriffixStrategy = shortBegriffixStrategy
    case .long: begriffixStrategy = longBegriffixStrategy
    case .availability: begriffixStrategy = availabilityBegriffixStrategy
    case .minPlaces: begriffixStrategy = minPlacesBegriffixStrategy
    default: begriffixStrategy = randomBegriffixStrategy
    }
    self.init(radix, begriffixStrategy: begriffixStrategy)
  }
}

extension SGSimulationResults.Trial {
  init(condition: Int, trial: Int, moves: [Begriffix.Move]) {
    self.condition = UInt32(condition)
    self.trial = UInt32(trial)
    self.moves = moves.map {SGSimulationResults.Move($0)}
  }
}

extension SGSimulationResults.Move {
  init(_ move: Begriffix.Move) {
    self.place = SGSimulationResults.Place(move.place)
    self.word = String(String.UnicodeScalarView(move.word))
    if let hits = move.hits {
      self.hits = hits.map {SGSimulationResults.Hit($0.key, $0.value)}
    }
  }
}

extension SGSimulationResults.Hit {
  init(_ place: Place, _ words: [Begriffix.Word]) {
    self.place = SGSimulationResults.Place(place)
    self.words = words.map {String(String.UnicodeScalarView($0))}
  }
}

extension SGSimulationResults.Place {
  init(_ place: Games.Place) {
    self.column = UInt32(place.start.column)
    self.row = UInt32(place.start.row)
    switch place.direction {
    case .horizontal: self.direction = .horizontal
    case .vertical: self.direction = .vertical
    }
  }
}