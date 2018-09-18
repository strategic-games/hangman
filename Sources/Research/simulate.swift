import Foundation
import Yams
import SwiftCLI

let research = Command(usage: "research") {_, _ in}
let simulate = Command(usage: "simulate file", parent: research) {flags, args in
  let url = URL(fileURLWithPath: args[0])
  if url.pathExtension == "yaml" {
    let data = try String(contentsOf: url)
    let decoder = YAMLDecoder()
    return try decoder.decode(BegriffixSimulation.self, from: data)
  } else {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(BegriffixSimulation.self, from: data)
  }
  let format = flags.getString(name: "format")
  if format == "yaml" {
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
let validate = Command(usage: "validate", parent: research) {_, _ in}
let demo = Command(usage: "demo", parent: research) {_, _ in}
class SimulateCommand: Command {
  struct Result: Codable {}
  let name = "simulate"
  let file = Parameter()
  let format = Key<String>("-t", "--format", "The output serialization format")
  func execute() throws {
    var simulation = try readSimulation()
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
