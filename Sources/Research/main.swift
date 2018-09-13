import SwiftCLI
import Utility

let cli = CLI(name: "research", version: Utility.Version.description, description: "An automation tool for game simulations")
cli.commands = [ValidateCommand(), SimulateCommand()]
cli.goAndExit()
