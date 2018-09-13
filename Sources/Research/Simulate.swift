import Foundation
import Yams
import SwiftCLI

class SimulateCommand: Command {
  struct Result: Codable {}
  let name = "simulate"
  let file = Parameter()
  let format = Key<String>("-t", "--format", "The output serialization format")
  func execute() throws {
    var simulation = try readSimulation()
    stdout <<< "version: \(simulation.info.version)"
    simulation.process()
    try writeSimulation(simulation)
  }
  func readSimulation() throws -> BegriffixSimulation {
    let url = URL(fileURLWithPath: file.value)
    if url.pathExtension == "yaml" {
      let data = try String(contentsOf: url)
      let decoder = YAMLDecoder()
      return try decoder.decode(BegriffixSimulation.self, from: data)
    } else {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      return try decoder.decode(BegriffixSimulation.self, from: data)
    }
  }
  func writeSimulation(_ simulation: BegriffixSimulation) throws {
    if format.value == "yaml" {
      let encoder = YAMLEncoder()
      let data = try encoder.encode(simulation)
      let url = URL(fileURLWithPath: "simulation.yaml")
      try data.write(to: url, atomically: true, encoding: .utf8)
    } else {
      let encoder = JSONEncoder()
      let data = try encoder.encode(simulation)
      let url = URL(fileURLWithPath: "simulation.json")
      try data.write(to: url)
    }
  }
}
