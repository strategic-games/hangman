import Guaka
import Utility

let radixCommand = Command(usage: "radix words pattern", configuration: configuration, run: execute)

private func configuration(command: Command) {
  command.shortMessage = "Read a word list as radix tree and search for a pattern"
}

private func execute(flags: Flags, args: [String]) {
  guard args.count == 2 else {
    rootCommand.fail(statusCode: 1, errorMessage: "Please enter a word list ID and a search pattern")
  }
  guard let words = WordList(rawValue: args[0])?.words() else {
    rootCommand.fail(statusCode: 1, errorMessage: "Invalid word list ID")
  }
  let radix = Radix()
  words.forEach {radix.insert($0)}
  let result = radix.search(pattern: args[1])
  guard result.count > 0 else {
    rootCommand.fail(statusCode: 0, errorMessage: "no words matching \(args[1]) were found")
  }
  result.forEach {print($0)}
}
