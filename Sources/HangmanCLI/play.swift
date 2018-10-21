import Foundation
import Guaka
import Utility
import Games

let playCommand = Command(usage: "play", configuration: configuration, run: execute)

private func configuration(command: Command) {
  command.shortMessage = "Play Begriffix interactively against the AI player used in simulations"
  let wordListFlag = Flag(
    shortName: "d",
    longName: "dictionary",
    value: "dictionary.pb",
    description: "The word list to use for the AI player"
  )
  let startLettersFlag = Flag(shortName: "l", longName: "letters", value: "laer", description: "The starting four-letter combination")
  let starterFlag = Flag(shortName: "s", longName: "starter", value: false, description: "play as the starting player against an AI opponent")
  command.add(flags: [startLettersFlag, wordListFlag, starterFlag])
}

private func execute(flags: Flags, args: [String]) {
  guard let startLetters = flags.getString(name: "letters"), startLetters.count == 4 else {
    playCommand.fail(statusCode: 1, errorMessage: "Please supply exactly four start letters")
  }
  print("preparing AI vocabulary")
  let path = flags.getString(name: "dictionary")!
  let url = URL(fileURLWithPath: path)
  let radix = Radix()
  do {
    let data = try Data(contentsOf: url)
    let list = try WordList(serializedData: data)
    list.words.forEach {radix.insert($0)}
  } catch {
    playCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
  let ai = Player(radix)
  print("AI is ready")
  let starter = flags.getBool(name: "starter")!
  var game = starter ? Begriffix(startLetters: startLetters, starter: ai.move, opponent: move) : Begriffix(startLetters: startLetters, starter: move, opponent: ai.move)
  game.notify = { status in
    if case .Moved(_, let game) = status {
      print(game.displayableBoard)
    }
  }
  do {
    try game.play()
  } catch {
    playCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}

private func move(_ game: Begriffix) -> Begriffix.Move? {
  let start: Point = ask("Which position do you want to start writing from?")
  let direction = Direction.Horizontal
  let word: String = ask("Which word to you want to write?")
  let place = Place(start: start, direction: direction, count: word.count)
  let move = Begriffix.Move(place, word.word)
  return move
}
