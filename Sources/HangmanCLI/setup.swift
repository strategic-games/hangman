import Guaka

func setupCommands() {
  rootCommand.add(subCommand: playCommand)
  rootCommand.add(subCommand: radixCommand)
  rootCommand.add(subCommand: simulateCommand)
  rootCommand.add(subCommand: importCommand)
}
