import Foundation
import Guaka
import Utility

let radixCommand = Command(
  usage: "radix",
  shortMessage: "Work with word lists",
  parent: rootCommand,
  run: nil
)

let searchCommand = Command(
  usage: "search pattern",
  shortMessage: "Read a word list as radix tree and search for a pattern",
  flags: [
    Flag(
      shortName: "d",
      longName: "dictionary",
      value: "dictionary.txt",
      description: "The file which contains the word list"
    )
  ],
  parent: radixCommand,
  run: search
)

private func search(flags: Flags, args: [String]) {
  let path = flags.getString(name: "dictionary")!
  let url = URL(fileURLWithPath: path)
  do {
    let text = try String(contentsOf: url)
    let radix = Radix()
    radix.insert(text.words)
    let result = args.count != 0 ? radix.search(pattern: args[0]) : radix.search()
    print(result)
  } catch {
    radixCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}

let text2protoCommand = Command(
  usage: "text2proto",
  shortMessage: "Convert word list from text to proto format",
  flags: [
    Flag(
      shortName: "i",
      longName: "input",
      value: "wordList.txt",
      description: "The text file path where the proto data should be read from"
    ),
    Flag(
      shortName: "o",
      longName: "output",
      value: "wordList.pb",
      description: "The file path where the proto data should be written"
    )
  ],
  parent: radixCommand,
  run: text2proto
)
private func text2proto(flags: Flags, args: [String]) {
  let input = flags.getString(name: "input")!
  let output = flags.getString(name: "output")!
  let urlIn = URL(fileURLWithPath: input)
  let urlOut = URL(fileURLWithPath: output)
  do {
    let text = try String(contentsOf: urlIn)
    let list = SGWordLists.Entry.with {
      $0.key = "file"
      $0.value = text.words
    }
    let data = try list.serializedData()
    try data.write(to: urlOut)
  } catch {
    rootCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}
