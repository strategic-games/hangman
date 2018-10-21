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
    let list = try WordList(contentsOf: url)
    let radix = Radix()
    radix.insert(list.words)
    let result = args.count != 0 ? radix.search(pattern: args[0]) : radix.search()
    print(result)
  } catch {
    radixCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}
