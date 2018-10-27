import Guaka

let rootCommand = Command(usage: "hangman", configuration: configuration, run: execute)

private func configuration(command: Command) {
  let versionFlag = Flag(
    shortName: "v",
    longName: "version",
    value: false,
    description: "Prints the version",
    inheritable: false
  )
  command.add(flag: versionFlag)
  command.inheritablePreRun = { flags, args in
    if let version = flags.getBool(name: "version"), version {
      print("Version " + SGVersion.current.description)
      return false
    }
    return true
  }
}

private func execute(flags: Flags, args: [String]) {
  print(rootCommand.helpMessage)
}
