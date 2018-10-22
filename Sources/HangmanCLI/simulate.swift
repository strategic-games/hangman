import Foundation
import Guaka

let simulateCommand = Command(
  usage: "simulate file",
  shortMessage: "Simulate game definitions and export the results",
  flags: [
    Flag(
      shortName: "o",
      longName: "out",
      type: String.self,
      description: "A directory path where the results file is written to (working directory by default)"
    )
  ],
  run: execute
)

private func execute(flags: Flags, args: [String]) {
  guard args.count != 0 else {
    simulateCommand.fail(statusCode: 1, errorMessage: "Error: please supply a file name")
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
    guard let streamer = SimulationStreamer(fileName: simulation.info.fileName, dir: out) else {
      rootCommand.fail(statusCode: 1, errorMessage: "couldn't create streamer")
      return
    }
    try simulation.run(streamer: streamer)
  } catch {
    print(error)
  }
}

let importCommand = Command(usage: "import file") { (flags, args) in
  guard args.count > 0 else {return}
  let url = URL(fileURLWithPath: args[0])
  do {
    let simulation = try SimulationResults(contentsOf: url)
    print(simulation.trials.count)
  } catch {
    print(error)
  }
}

