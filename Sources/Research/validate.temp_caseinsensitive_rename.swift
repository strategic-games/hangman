import Foundation
import Guaka

let validateCommand = Command(usage: "validate file", configuration: configuration, run: execute)

private func configuration(command: Command) {
  command.shortMessage = "read and validate an experiment description"
}

private func execute(flags: Flags, args: [String]) {
  let file = args[0]
  do {
    let url = URL(fileURLWithPath: file)
    let jsonData = try Data(contentsOf: url)
    let jsonDecoder = JSONDecoder()
    var desc = try jsonDecoder.decode(BegriffixSimulation.self, from: jsonData)
    desc.process()
    let jsonEncoder = JSONEncoder()
    let jsonData2 = try jsonEncoder.encode(desc)
    let url2 = URL(fileURLWithPath: "output_"+file)
    try jsonData2.write(to: url2)
  } catch {
    print(error)
  }
}
