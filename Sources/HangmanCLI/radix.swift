import Foundation
import Guaka
import Utility

let radixCommand = Command(usage: "radix pattern", configuration: configuration, run: execute)

private func configuration(command: Command) {
  command.shortMessage = "Read a word list as radix tree and search for a pattern"
  let dictionaryFlag = Flag(
    shortName: "d",
    longName: "dictionary",
    value: "dictionary.txt",
    description: "The file which contains the word list"
  )
  command.add(flag: dictionaryFlag)
}

private func execute(flags: Flags, args: [String]) {
  let path = flags.getString(name: "dictionary")!
  let url = URL(fileURLWithPath: path)
  do {
    let content = try String(contentsOf: url)
    let radix = loadWordList(content)
    let result = args.count != 0 ? radix.search(pattern: args[0]) : radix.search()
    print(result)
  } catch {
    radixCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}

func loadWordList(_ contents: String) -> Radix {
  let dict = contents.lowercased().unicodeScalars
    .split(separator: "\n")
    .drop(while: {$0.first == "#"})
    .map {Array($0.prefix(while: {$0 != " "}))}
  let radix = Radix()
  dict.forEach {radix.insert($0)}
  return radix
}
