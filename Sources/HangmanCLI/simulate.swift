import Foundation
import Guaka
import Yams
import SimulationDescription

let simulateCommand = Command(usage: "simulate file", configuration: configuration, run: execute)

private func configuration(command: Command) {
  command.shortMessage = "Simulate game definitions and export the results"
  let formatFlag = Flag(shortName: "t", longName: "format", value: "json", description: "The output serialization format to write the results to")
  command.add(flag: formatFlag)
}

private func execute(flags: Flags, args: [String]) {
  guard args.count != 0 else {
    simulateCommand.fail(statusCode: 1, errorMessage: "Error: please supply a file name")
  }
  do {
    var simulation = try readSimulation(file: args[0])
    simulation.process()
    let format = flags.getString(name: "format")!
    try writeSimulation(simulation, format: format)
  } catch {
    print(error)
  }
}

private func readSimulation(file: String) throws -> Simulation {
  let url = URL(fileURLWithPath: file)
  if url.pathExtension == "yaml" {
    let data = try String(contentsOf: url)
    let decoder = YAMLDecoder()
    return try decoder.decode(Simulation.self, from: data)
  } else {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(Simulation.self, from: data)
  }
}

private func writeSimulation(_ simulation: Simulation, format: String) throws {
  if format == "yaml" {
    let url = URL(fileURLWithPath: simulation.info.filename + ".yaml")
    let encoder = YAMLEncoder()
    let data = try encoder.encode(simulation)
    try data.write(to: url, atomically: true, encoding: .utf8)
  } else {
    let url = URL(fileURLWithPath: simulation.info.filename + ".json")
    let encoder = JSONEncoder()
    let data = try encoder.encode(simulation)
    try data.write(to: url)
  }
}
