import Foundation
import SwiftCLI

class ValidateCommand: Command {
  let name = "validate"
  let shortDescription = "read and validate an experiment description"
  let file = Parameter()
  func execute() throws {
    let url = URL(fileURLWithPath: file.value)
    let jsonData = try Data(contentsOf: url)
    let jsonDecoder = JSONDecoder()
    var desc = try jsonDecoder.decode(BegriffixSimulation.self, from: jsonData)
    desc.process()
    let jsonEncoder = JSONEncoder()
    let jsonData2 = try jsonEncoder.encode(desc)
    let url2 = URL(fileURLWithPath: "output_"+file.value)
    try jsonData2.write(to: url2)
  }
}
