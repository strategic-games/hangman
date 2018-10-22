import Guaka

func setupCommands() {
  rootCommand.add(subCommand: playCommand)
  rootCommand.add(subCommand: radixCommand)
  radixCommand.add(subCommand: searchCommand)
  radixCommand.add(subCommand: text2protoCommand)
  rootCommand.add(subCommand: simulateCommand)
  rootCommand.add(subCommand: importCommand)
}
