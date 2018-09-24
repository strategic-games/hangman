import Guaka
import Utility
import Games

let playCommand = Command(usage: "play", configuration: configuration, run: execute)

private func configuration(command: Command) {
  command.shortMessage = "Play Begriffix interactively against the AI player used in simulations"
  let wordListFlag = Flag(shortName: "w", longName: "words", value: WordList.ScrabbleDict, description: "The word list to use for the AI player")
  let startLettersFlag = Flag(shortName: "l", longName: "letters", value: "laer", description: "The starting four-letter combination")
  let starterFlag = Flag(shortName: "s", longName: "starter", value: false, description: "play as the starting player against an AI opponent")
  command.add(flags: [startLettersFlag, wordListFlag, starterFlag])
}

private func execute(flags: Flags, args: [String]) {
  guard let startLetters = flags.getString(name: "letters"), startLetters.count == 4 else {
    rootCommand.fail(statusCode: 1, errorMessage: "Please supply exactly four start letters")
  }
  let wordList = flags.get(name: "words", type: WordList.self)!
  print("preparing AI vocabulary")
  let ai = Player(.full(wordList))
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
    print(error)
  }
}

private func move(_ game: Begriffix) -> (Begriffix.Move, [Begriffix.Hit])? {
  let start: Point = ask("Which position do you want to start writing from?")
  let direction = Direction.Horizontal
  let word: String = ask("Which word to you want to write?")
  let place = Place(start: start, direction: direction, count: word.count)
  let move = Begriffix.Move(place, word.word)
  return (move: move, hits: [])
}
