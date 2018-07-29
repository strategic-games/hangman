import Foundation
import SwiftCLI
import Hangman

class RadixGroup: CommandGroup {
  let name = "radix"
  let shortDescription = "radix commands"
  let children: [Routable] = [
    RadixConvertCommand(),
    RadixSearchCommand()
  ]
}

class RadixConvertCommand: Command {
  let name = "convert"
  let shortDescription = "Read a word list from a txt file and serialize to json"
  let input = OptionalParameter()
  let output = OptionalParameter()
  func execute() throws {
    let txt = URL(fileURLWithPath: input.value ?? "dictionaries/german.txt")
    let json = URL(fileURLWithPath: output.value ?? "dictionaries/german.json")
    let content = try String(contentsOf: txt).lowercased()
    let radix = Radix()
    radix.insert(text: content)
    let jsonEncoder = JSONEncoder()
    let jsonData = try jsonEncoder.encode(radix)
    try jsonData.write(to: json)
  }
}

class RadixSearchCommand: Command {
  let name = "search"
  let shortDescription = "Read a radix from json and search for a pattern"
  let pattern = Parameter()
  let input = Key<String>("-i", "--input", description: "Path to a json file containing a radix serialization")
  let type = Key<String>("-t", "--type", "The format of the input file")
  func execute() throws {
    let type = self.type.value ?? "txt"
    let file = URL(fileURLWithPath: input.value ?? "Resources/dictionaries/german.\(type)")
    let radix: Radix
    if type == "json" {
      let jsonData = try Data(contentsOf: file)
      let jsonDecoder = JSONDecoder()
      radix = try jsonDecoder.decode(Radix.self, from: jsonData)
    } else if type == "txt" {
      let content = try String(contentsOf: file)
      radix = Radix()
      stdout <<< "creating radix"
      radix.insert(text: content)
      stdout <<< "created"
    } else {return}
    stdout <<< radix.match(pattern.value).description
  }
}
