import Foundation
import Guaka

let simulationCommand = Command(
  usage: "simulation",
  shortMessage: "Work with simulations"
)

let runCommand = Command(
  usage: "run file",
  shortMessage: "Simulate game definitions and export the results",
  flags: [
    Flag(
      shortName: "o",
      longName: "out",
      type: String.self,
      description: "A directory path where the results file is written to (working directory by default)"
    )
  ],
  parent: simulationCommand
) { (flags: Flags, args: [String]) in
  guard args.count != 0 else {
    rootCommand.fail(statusCode: 1, errorMessage: "Error: please supply a file name")
  }
  let out = flags.getString(name: "out")
  do {
    let url = URL(fileURLWithPath: args[0])
    let data = try Data(contentsOf: url)
    var simulation: Simulation
    switch url.pathExtension {
    case "json":
      simulation = try Simulation(jsonUTF8Data: data)
    default:
      simulation = try Simulation(serializedData: data)
    }
    simulation.info.date = .init(date: Date())
    simulation.info.version = Version.current
    guard let streamer = SimulationStreamer(fileName: simulation.info.fileName, dir: out) else {
      rootCommand.fail(statusCode: 1, errorMessage: "couldn't create streamer")
    }
    try simulation.run(streamer: streamer)
  } catch {
    rootCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}

let loadCommand = Command(
  usage: "load file",
  shortMessage: "Load results from a file and print some metadata",
  parent: simulationCommand
) { (flags, args) in
  guard args.count > 0 else {return}
  let url = URL(fileURLWithPath: args[0])
  do {
    let simulation = try SimulationResults(contentsOf: url)
    print("title: ", simulation.config.info.title)
    print("date: ", simulation.config.info.date.date)
    print("number of trials: ", simulation.trials.count)
  } catch {
    rootCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}
