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
    var simulation: BegriffixSimulation = try deserialize(args[0])
    try simulation.process()
    let format = flags.getString(name: "format")!
    try serialize(simulation, format: format)
  } catch {
    print(error)
  }
}

private func deserialize<T: Decodable>(_ path: String) throws -> T {
  let url = URL(fileURLWithPath: path)
  if url.pathExtension == "yaml" {
    let data = try String(contentsOf: url)
    let decoder = YAMLDecoder()
    return try decoder.decode(T.self, from: data)
  } else {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
  }
}

private func serialize<T: Encodable&FileNameConvertible>(_ value: T, format: String) throws {
  if format == "yaml" {
    let url = URL(fileURLWithPath: value.fileName + ".yaml")
    let encoder = YAMLEncoder()
    let data = try encoder.encode(value)
    try data.write(to: url, atomically: true, encoding: .utf8)
  } else {
    let url = URL(fileURLWithPath: value.fileName + ".json")
    let encoder = JSONEncoder()
    let data = try encoder.encode(value)
    try data.write(to: url)
  }
}
