import Guaka

let rootCommand = Command(usage: "hangman", configuration: configuration, run: execute)

private func configuration(command: Command) {
  let versionFlag = Flag(shortName: "v", longName: "version", value: false, description: "Prints the version", inheritable: false)
  command.add(flag: versionFlag)
  command.inheritablePreRun = { flags, args in
    if let version = flags["version"]?.value as? Bool, version {
      print("Version \(Version.description)")
      return false
    }
    return true
  }
}

private func execute(flags: Flags, args: [String]) {
  print(rootCommand.helpMessage)
}
