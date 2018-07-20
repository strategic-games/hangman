import SwiftCLI

let cli = CLI(name: "BegriffixShell", version: "0.0.1", description: "A cli for Begriffix")
cli.commands = [RadixGroup(), PlayCommand(), TestCommand()]
cli.goAndExit()
