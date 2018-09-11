import Foundation
import SwiftCLI

class SimulateCommand: Command {
  struct Result: Codable {}
  let name = "simulate"
  let file = Parameter()
  func execute() throws {
    var simulation = try readSimulation()
    simulation.process()
    try writeSimulation(simulation)
  }
  func readSimulation() throws -> BegriffixSimulation {
    let url = URL(fileURLWithPath: file.value)
    let jsonData = try Data(contentsOf: url)
    let jsonDecoder = JSONDecoder()
    return try jsonDecoder.decode(BegriffixSimulation.self, from: jsonData)
  }
  func writeSimulation(_ simulation: BegriffixSimulation) throws {
    let jsonEncoder = JSONEncoder()
    let jsonData = try jsonEncoder.encode(simulation)
    let url = URL(fileURLWithPath: "simulation.json")
    try jsonData.write(to: url)
  }
}
