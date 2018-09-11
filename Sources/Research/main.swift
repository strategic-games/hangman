import SwiftCLI

let cli = CLI(name: "research", version: "0.0.1", description: "An automation tool for game simulations")
cli.commands = [ValidateCommand(), SimulateCommand()]
cli.goAndExit()
