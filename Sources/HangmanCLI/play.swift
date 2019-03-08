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
) { (flags, _) in
  guard let startLetters = flags.getString(name: "letters"), startLetters.count == 4 else {
    rootCommand.fail(statusCode: 1, errorMessage: "Please supply exactly four start letters")
  }
  guard let board = try? BegriffixBoard(startLetters: startLetters) else {
    rootCommand.fail(statusCode: 1, errorMessage: "The board couldn't be created with the given start letters")
  }
  print("preparing AI vocabulary …")
  let path = flags.getString(name: "dictionary")!
  let url = URL(fileURLWithPath: path)
  let radix = Radix()
  do {
    let text = try String(contentsOf: url)
    radix.insert(text.words)
  } catch {
    rootCommand.fail(statusCode: 1, errorMessage: "\(error)")
  }
  let player = Player(radix)
  print("AI is ready")
  let starter = flags.getBool(name: "starter")!
  let players: DyadicPlayers<Begriffix>
  if starter {
    print("You will be the starter")
    players = .init(starter: player.move, opponent: move)
  } else {
    print("You will be the opponent")
    players = .init(starter: move, opponent: player.move)
  }
  var game = Begriffix(board: board, players: players)
  game.notify = { status in
    if case .moved(_, let game) = status {
      print(game.board)
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
  if let dir = game.dir {
    print("Direction is \(dir), because we are in turn 1 and you are opponent")
    direction = dir
  } else {
    let dirBool = agree("Do you want to write horizontally? Otherwise vertically.")
    direction = dirBool ? .horizontal : .vertical
  }
  let word: String = ask("Which word to you want to write?")
  let place = Place(start: start, direction: direction, count: word.count)
  guard game.board.contains(place) else {
    print("Invalid move, giving up.")
    return nil
  }
  let move = Begriffix.Move(place, word.word)
  return move
}
