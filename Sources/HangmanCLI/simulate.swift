import Foundation
import Guaka

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
    try simulation.run()
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

