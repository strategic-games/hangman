import Foundation
import Guaka
import Utility
import Games

let playCommand = Command(
  usage: "play",
  shortMessage: "Play Begriffix interactively against the AI player used in simulations",
  flags: [
    Flag(
      shortName: "d",
      longName: "dictionary",
      value: "dictionary.pb",
      description: "The word list to use for the AI player"
    ),
    Flag(
      shortName: "l",
      longName: "letters",
      value: "laer",
      description: "The starting four-letter combination"
    ),
    Flag(
      shortName: "s",
      longName: "starter",
      value: false,
      description: "play as the starting player against an AI opponent"
    )
  ]
) { (flags: Flags, args: [String]) in
  guard let startLetters = flags.getString(name: "letters"), startLetters.count == 4 else {
    rootCommand.fail(statusCode: 1, errorMessage: "Please supply exactly four start letters")
  }
  print("preparing AI vocabulary …")
  let path = flags.getString(name: "dictionary")!
  let url = URL(fileURLWithPath: path)
  let radix = Radix()
  do {
    let list = try WordList(contentsOf: url)
    radix.insert(list.words)
  } catch {
    rootCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
  let ai = Player(radix)
  print("AI is ready")
  let starter = flags.getBool(name: "starter")!
  print(starter ? "You will be the starter" : "You will be the opponent")
  var game = starter ? Begriffix(startLetters: startLetters, starter: ai.move, opponent: move) : Begriffix(startLetters: startLetters, starter: move, opponent: ai.move)
  game.notify = { status in
    if case .Moved(_, let game) = status {
      print(game.displayableBoard)
    }
  }
  do {
    try game.play()
  } catch {
    rootCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
}

private func move(_ game: Begriffix) -> Begriffix.Move? {
  let start: Point = ask("Which position do you want to start writing from?")
  let direction: Direction
  switch game.phase {
  case .Restricted(let dir):
    print("Direction is \(dir), because we are in turn 1")
    direction = dir
  case .Liberal:
    let dirBool = agree("Do you want to write horizontally? Otherwise vertically.")
    direction = dirBool ? .Horizontal : .Vertical
  case .KnockOut:
    print("KO is not yet implemented")
    return nil
  }
  let word: String = ask("Which word to you want to write?")
  let place = Place(start: start, direction: direction, count: word.count)
  guard game.contains(place) else {
    print("Invalid move, giving up.")
    return nil
  }
  let move = Begriffix.Move(place, word.word)
  return move
}
