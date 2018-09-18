import Guaka
import Utility

let rootCommand = Command(usage: "research", configuration: configuration, run: execute)

private func configuration(command: Command) {
  command.add(flags: [
    Flag(longName: "version", value: false,
         description: "Prints the version", inheritable: false),
    ]
  )
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
